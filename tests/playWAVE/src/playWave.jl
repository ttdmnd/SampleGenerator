###############################################################################
# playWave.jl - Play all WAV files in the wave-samples directory
#
# This script defines a module for reading and playing WAV files using WAV.jl.
# It scans the 'wave-samples' directory, plays each WAV file found, and prints
# basic information about each file. Errors are handled gracefully.
#
# Usage:
#   julia playWave.jl
#
# Requirements:
#   - WAV.jl package installed in the Julia environment.
#   - WAV files located in the 'wave-samples' directory.
###############################################################################

__precompile__(false)

module playWave

using WAV

"""
    play_wav_file(file_path::String)

    Reads and plays a WAV file from the given path.
    Prints basic info and handles errors gracefully.
"""
function play_wav_file(file_path::String)

    if !isfile(file_path)

        println("Error: The file '$file_path' was not found.")
        return

    end

    try

        y, fs = wavread(file_path)

        println("Reading '$file_path'...")
        println("Sample Rate: $fs Hz")
        println("Number of samples: $(length(y))")
        println("Playing the audio...")

        wavplay(y, fs)
        
        println("Playback finished.")

    catch e

        println("An error occurred while trying to play the WAV file.")
        println("Error details: $e")

    end

end

"""
    main()

    Entry point for the script.
    Iterates over all WAV files in the 'wave-samples' directory and plays them.
    Pauses briefly between files.
"""
function main()

    for file in readdir(

        abspath(joinpath(dirname(@__FILE__), "..", "..", "..", "wave-samples")), 
        join=true,

    )
        if endswith(file, ".wav")

            println("\nProcessing file: $file...\n")
            play_wav_file(file)
            sleep(1)

        end

    end

end

main()

end