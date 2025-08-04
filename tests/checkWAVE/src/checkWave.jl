###############################################################################
# checkWave.jl - Check properties of WAV files in the wave-samples directory
#
# This script defines a module for verifying WAV file properties using WAV.jl.
# It scans the 'wave-samples' directory and checks if each WAV file matches
# specific criteria (RIFF format, 8-bit unsigned, 800 Hz sample rate).
# Results and errors are printed for each file.
#
# Usage:
#   julia checkWave.jl
#
# Requirements:
#   - WAV.jl package installed in the Julia environment.
#   - WAV files located in the 'wave-samples' directory.
###############################################################################

__precompile__(false)

module checkWave

using WAV

"""
    check_wav_properties(file_path::String)::Bool

    Checks if a given WAV file matches the required properties:
    - RIFF format (checked implicitly by WAV.jl)
    - 8-bit unsigned data type
    - 800 Hz sample rate

    Arguments:
        file_path: Full path to the WAV file.

    Returns:
        true if the file matches all properties, false otherwise.

    This function reads the WAV file and compares its sample rate to 800 Hz.
    It prints a report for each file and handles errors gracefully.
"""
function check_wav_properties(file_path::String)::Bool
    # Try to read the WAV file and check its sample rate.
    try
        _, fs = wavread(file_path)
        is_800_hz = fs == 800

        println("\n--- WAV File Check Report ---")
        
        println("File: $file_path")
        println("Sample Rate (fs): $fs Hz")

        println("-----------------------------")

        if is_800_hz

            println("The file is a RIFF WAV, 8-bit unsigned, 800 Hz. ✅")
            return true

        else

            println("The file DOES NOT match the specifications. ❌")
            println("800 Hz: ", is_800_hz ? "Yes" : "No")
            return false

        end

    catch e

        # Print error details if the file is invalid or not found.
        println("\nError reading the file. It might not be a valid WAV format or the file path is incorrect.")
        println("Error details: $e")

        return false

    end

end

"""
    main()

    Entry point for the script.
    Iterates over all WAV files in the 'wave-samples' directory and checks their properties.
    Prints a separator after each file for clarity.
"""
function main()

    # Loop through all files in the wave-samples directory.
    for file in readdir(

        abspath(joinpath(dirname(@__FILE__), "..", "..", "..", "wave-samples")), 
        join=true,

    )
        # Only process files with .wav extension.
        if endswith(file, ".wav")

            check_wav_properties(file)

        end

        # Print separator for clarity between files.
        println("\n" * "---" ^ 10 * "\n")

    end

end

main()

end