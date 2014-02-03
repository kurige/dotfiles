#!/usr/local/bin/zsh
# Display the terminal 255 colors by blocks


# Long space is long
local space=" "
for i in {0..22}; do space=$space" "; done

# Number of color lines per block
local lines=6
# Number of blocks per terminal line
local blocks=2

# Tmp var to hold the current line in a block 
local m=0
# Tmp var to hold how many blocks are filled
local b=0
typeset -A grid

# We want to display the blocks side by side, so it means we'll have to create
# each line one my one then display all of them, and after that jump to the
# next set of blocks
for color in {016..255}; do
    # Current line in a block
    m=$((($color-16)%$lines))

    # Appending the displayed color to the line
    grid[$m]=$grid[$m]"[01m[38;5;${color}m#${color} [48;5;${color}m${space}[00m  "
    
    # Counting how many blocks are filled
    [[ $m = 5 ]] && b=$(($b+1))

    # Enough blocks for this line, display them
    if [[ $b = $blocks ]]; then
        # Reset block counter
        b=0;
        # Display each line
        for j in {0..5}; do
            echo $grid[$j]
            grid[$j]=""
        done
        echo ""
    fi
done

# Display each remaining blocks
for j in {0..5}; do
    echo $grid[$j]
    grid[$j]=""
done
