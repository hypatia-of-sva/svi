/* svi by Sva - smol vi (simple, minimal, optimal, lean, or stupid, mad, obnoxious and lightheaded)  */

package svi

import "core:fmt"
import "core:os"
import "core:c/libc"
import "core:time"


// config constants

// we presume noone uses crazy terminal sizes..
// otherwise we quit down below.
// this allows us to use static memory instead of allocators, when we only need one allocation.
min_screen_height :: 10
min_screen_width :: 10
max_screen_height :: 512
max_screen_width :: 512

// size of read buffer in bytes
read_buffer_size :: 1024



// runtime variables of the editor

screenbuffer : [max_screen_height][max_screen_width]rune
height, width : int
curr_x, curr_y : int = 0, 0

// always read a whole input block
// allows detecting multiple keys down at once
readbuffer: [read_buffer_size]u8


vi_mode :: enum {
    ex, visual, insert
}

current_mode : vi_mode = vi_mode.visual

// flags to not overwhelm the terminal (emulator)
screen_needs_drawing : bool = true
cursor_needs_updating : bool = true




// key inputs (test on windows!):

BACKSPACE :: 127 // i.e. DEL
ENTER :: 13 // i.e CR, \r, = CTRL-M
CTRL_A :: 1 // i.e. SOH
CTRL_B :: 2
CTRL_C :: 3
//...
CTRL_Z :: 26
ESCAPE :: 27



main :: proc() {
    // call the terminal init functions
    _set_terminal()
    defer _restore_terminal()

    height, width = expand_values(_get_window_size())

    // terminal size sanity check
    if (height < min_screen_height || height > max_screen_height || width < min_screen_width || width > max_screen_width) {
        fmt.printf("Error: dimensions of terminal (y = %d, x = %d) not allowed (must be at least %dx%d and at most %dx%d)", height , width, min_screen_height, min_screen_width, max_screen_height, max_screen_width )
        os.exit(1)
    }

    // initial empty buffer
    for i in 0..<height {
        screenbuffer[i][0] = '~'
        for j in 1..<width {
            screenbuffer[i][j] = ' '
        }
    }

    // event loop
    for {
        // read the input
        n_read, err := os.read(os.stdin, readbuffer[:])

        // handle the input
        for c in readbuffer do switch current_mode {
            case vi_mode.visual:
                switch c {
                    case ':':
                        current_mode = vi_mode.ex
                        //fmt.print("mode switched to ex")
                        screenbuffer[height-1][0] = ':'
                        for j in 1..<width {
                            screenbuffer[height-1][j] = ' '
                        }
                        curr_x = 1
                        curr_y = height-1
                        screen_needs_drawing = true

                    case 'h':
                        curr_x -= 1
                        cursor_needs_updating = true

                    case 'j':
                        curr_y += 1
                        cursor_needs_updating = true

                    case 'k':
                        curr_y -= 1
                        cursor_needs_updating = true

                    case 'l':
                        curr_x += 1
                        cursor_needs_updating = true

                }

            case vi_mode.ex:
                switch c {

                    case 'a'..='z':
                        screenbuffer[curr_y][curr_x] = rune(c)
                        curr_x += 1
                        screen_needs_drawing = true
                    case ENTER:
                        if(curr_y == height-1 && curr_x == 2 && screenbuffer[curr_y][curr_x-1] == 'q') do return
                        curr_x, curr_y = 0, 0
                        for j in 0..<width {
                            screenbuffer[height-1][j] = ' '
                        }
                        current_mode = vi_mode.visual
                        screen_needs_drawing = true
                }


            case vi_mode.insert:

        }

        /*
        time.sleep(1000000000)
        written := false
        for r in readbuffer {
            if r != 0 {
                fmt.print(r, ':')
                written = true
            }

        }
        if written do fmt.print(';')
        */

        // zero the input buffer (so to not handle characters twice)
        readbuffer = {}


        // draw the screen if necessary
        if(screen_needs_drawing) {
            //set the curser back to the beginning
            fmt.print("\e[H")

            //print the new screen
            for i in 0..<height {
                if(i > 0) {
                    os.write_rune(os.stdout,'\r')
                    os.write_rune(os.stdout,'\n')
                }
                for j in 0..<width {
                    os.write_rune(os.stdout, screenbuffer[i][j])
                }
            }

            // cursor is now at end of screen and needs to be reset
            cursor_needs_updating = true

            //say that you updated the screen
            screen_needs_drawing = false
        }

        // update the cursor if necessary
        if(cursor_needs_updating) {

            // clamp position to screen
            if(curr_x < 0) do curr_x = 0
            if(curr_x >= width) do curr_x = width-1
            if(curr_y < 0) do curr_y = 0
            if(curr_y >= height) do curr_x = height-1

            //reset the curser to its position
            fmt.printf("\e[%d;%dH", curr_y+1, curr_x+1)

            // say that you updated the cursor
            cursor_needs_updating = false
        }

    }


}
