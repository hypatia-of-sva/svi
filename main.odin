/* svi by Sva - smol vi (simple, minimal, optimal, lean, or stupid, mad, obnoxious and lightheaded)  */

package svi

import "core:fmt"
import "core:os"
import "core:c/libc"
import "core:time"



// we presume noone uses crazy terminal sizes..
// otherwise we quit down below.
// this allows us to use static memory instead of allocators, when we only need one allocation.
screenbuffer : [512][512]rune
height, width : int
curr_x, curr_y : int = 0, 0



readbuffer: [1024]u8


vi_mode :: enum {
    ex, visual, insert
}

current_mode : vi_mode = vi_mode.visual


screen_needs_drawing : bool = true


/*
putrune :: proc(r : rune, x : int, y : int) {
    if(y == curr_y && x == curr_x) os.write_rune(os.stdout, r)
    screenbuffer[y][x] = r
}
*/


main :: proc() {



    //fmt.print("\e[2J\e[H")

    _set_terminal()
    defer _restore_terminal()


    height, width = expand_values(_get_window_size())

    // terminal size sanity check
    if (height < 10 || height > 512 || width < 10 || width > 512) {
        fmt.print("Error: dimensions of terminal (y = ", height, ",x =", width, ") not allowed (must be at least 10x10 and at most 512x512)" )
        os.exit(1)
    }

    //fmt.print(height, width)


    for i in 0..<height {
        screenbuffer[i][0] = '~'
        for j in 1..<width {
            screenbuffer[i][j] = ' '
        }
    }



    for {
        //r := libc.getchar()


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
                }

            case vi_mode.ex:
                switch c {

                    case 'a'..='z':
                        screenbuffer[curr_y][curr_x] = rune(c)
                        curr_x += 1
                        screen_needs_drawing = true
                    case 13:
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

        readbuffer = {}


        // draw the screen
        if(screen_needs_drawing) {
            //set the curser back to the beginning and clear the screen
            fmt.print("\e[2J\e[H")

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

            //reset the curser to its position
            fmt.printf("\e[%d;%dH", curr_y+1, curr_x+1)

            //say that you updated the screen
            screen_needs_drawing = false
        }

    }


}
