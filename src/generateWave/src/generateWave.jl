###############################################################################
# generateWave.jl - Generate WAV files from MIDI notes
#
# This script defines a module for generating WAV files from MIDI input using
# custom RIFF header construction and basic waveform synthesis (square, triangle,
# sine). It reads MIDI files from the 'midi-samples' directory, extracts note
# information, and writes corresponding WAV files to disk.
#
# Usage:
#   julia generateWave.jl
#
# Requirements:
#   - MIDI.jl package installed in the Julia environment.
#   - MIDI files located in the 'midi-samples' directory.
###############################################################################

__precompile__(false)

module generateWave

using MIDI

# ---------------------------------------------------------------------------
# RIFF Header Struct and Functions
# ---------------------------------------------------------------------------

"""
    struct RIFFHeader

    Structure representing the RIFF header for a WAV file.
    Contains all necessary fields for a valid PCM WAV file.
"""
struct RIFFHeader
    chunk_id::String
    chunk_size::UInt32
    format::String
    subchunk1_id::String
    subchunk1_size::UInt32
    audio_format::UInt16
    num_channels::UInt16
    sample_rate::UInt32
    byte_rate::UInt32
    block_align::UInt16
    bits_per_sample::UInt16
    subchunk2_id::String
    subchunk2_size::UInt32
end

"""
    generate_riff_header(num_samples::Int, sample_rate::Int=800) -> RIFFHeader

    Generates a properly formatted RIFF header for a WAV file.

    Arguments:
        num_samples: Number of audio samples.
        sample_rate: Sample rate in Hz (default 800).

    Returns:
        RIFFHeader struct with all fields set.
"""
function generate_riff_header(num_samples::Int, sample_rate::Int=800)

    bits_per_sample = 8
    num_channels = 1
    subchunk2_size = UInt32(num_samples * num_channels * bits_per_sample / 8)
    chunk_size = UInt32(36 + subchunk2_size)
    byte_rate = UInt32(sample_rate * num_channels * bits_per_sample / 8)
    block_align = UInt16(num_channels * bits_per_sample / 8)

    RIFFHeader(
        "RIFF",
        chunk_size,
        "WAVE",
        "fmt ",
        UInt32(16),
        UInt16(1),  # PCM format
        UInt16(num_channels),
        UInt32(sample_rate),
        byte_rate,
        block_align,
        UInt16(bits_per_sample),
        "data",
        subchunk2_size
    )

end

"""
    write_wav_file(filename::String, header::RIFFHeader, samples::Vector{UInt8})

    Writes a complete WAV file to disk using the provided RIFF header and sample data.

    Arguments:
        filename: Output WAV file path.
        header: RIFFHeader struct.
        samples: Vector of 8-bit unsigned samples.
"""
function write_wav_file(filename::String, header::RIFFHeader, samples::Vector{UInt8})

    open(filename, "w") do io

        write(io, Vector{UInt8}(header.chunk_id))
        write(io, header.chunk_size % UInt32)
        write(io, Vector{UInt8}(header.format))
        write(io, Vector{UInt8}(header.subchunk1_id))
        write(io, header.subchunk1_size)
        write(io, header.audio_format)
        write(io, header.num_channels)
        write(io, header.sample_rate)
        write(io, header.byte_rate)
        write(io, header.block_align)
        write(io, header.bits_per_sample)
        write(io, Vector{UInt8}(header.subchunk2_id))
        write(io, header.subchunk2_size)
        write(io, samples)

    end

end

# ---------------------------------------------------------------------------
# Waveform Generation Functions
# ---------------------------------------------------------------------------

"""
    generate_square_wave(freq::Float64, duration::Float64, sample_rate::Int=800)

    Generates an 8-bit unsigned square wave.

    Arguments:
        freq: Frequency in Hz.
        duration: Duration in seconds.
        sample_rate: Sample rate in Hz (default 800).

    Returns:
        Vector{UInt8} containing the waveform samples.
"""
function generate_square_wave(freq::Float64, duration::Float64, sample_rate::Int=800)

    samples_count = round(Int, duration * sample_rate)
    waveform = Vector{UInt8}(undef, samples_count)
    period = sample_rate / freq

    for i in 1:samples_count

        pos_in_cycle = mod(i - 1, period)
        waveform[i] = pos_in_cycle < period / 2 ? 0xFF : 0x00

        waveform[i] = UInt8(waveform[i])

    end

    return waveform

end

"""
    generate_triangle_wave(freq::Float64, duration::Float64, sample_rate::Int=800)

    Generates an 8-bit unsigned triangle wave.

    Arguments:
        freq: Frequency in Hz.
        duration: Duration in seconds.
        sample_rate: Sample rate in Hz (default 800).

    Returns:
        Vector{UInt8} containing the waveform samples.
"""
function generate_triangle_wave(freq::Float64, duration::Float64, sample_rate::Int=800)

    samples_count = round(Int, duration * sample_rate)
    waveform = Vector{UInt8}(undef, samples_count)

    period = sample_rate / freq
    half_period = period / 2

    for i in 1:samples_count

        pos_in_cycle = mod(i - 1, period)

        if pos_in_cycle < half_period

            value = (0xFF / half_period) * pos_in_cycle

        else

            value = 0xFF - (0xFF / half_period) * (pos_in_cycle - half_period)

        end

        waveform[i] = round(UInt8, value)

    end

    return waveform

end

"""
    generate_senoid_wave(freq::Float64, duration::Float64, sample_rate::Int=800)

    Generates an 8-bit unsigned sine wave.

    Arguments:
        freq: Frequency in Hz.
        duration: Duration in seconds.
        sample_rate: Sample rate in Hz (default 800).

    Returns:
        Vector{UInt8} containing the waveform samples.
"""
function generate_senoid_wave(freq::Float64, duration::Float64, sample_rate::Int=800)

    samples_count = round(Int, duration * sample_rate)
    waveform = Vector{UInt8}(undef, samples_count)

    period = sample_rate / freq

    for i in 1:samples_count

        pos_in_cycle = mod(i - 1, period)
        value = (0xFF / 2) * (1 + sin(2 * pi * pos_in_cycle / period))

        waveform[i] = round(UInt8, value)

    end

    return waveform

end

# ---------------------------------------------------------------------------
# Main Processing Functions
# ---------------------------------------------------------------------------

"""
    process_midi_note(midi_file::String, output_prefix::String)

    Processes a MIDI file and generates corresponding WAV files for each waveform type.

    Arguments:
        midi_file: Path to the MIDI file.
        output_prefix: Prefix for output WAV files.

    This function reads the MIDI file, extracts the note, calculates its frequency
    and duration, generates square, triangle, and sine waves, and writes them as WAV files.
"""
function process_midi_note(midi_file::String, output_prefix::String)

    midi_data = readMIDIFile(midi_file)
    tracks = midi_data.tracks

    notes = Vector{MIDI.Note}()

    for track in tracks

        append!(notes, getnotes(track))

    end

    if length(notes) != 1

        error("The MIDI file must contain exactly one note, but contains $(length(notes)).")
    
    end

    note = notes[1]
    freq = 440.0 * (2.0^((note.pitch - 69)/12))

    duration = Float64(note.duration / 3000)

    square_wave = generate_square_wave(freq, duration, 800)
    triangle_wave = generate_triangle_wave(freq, duration, 800)
    senoid_wave = generate_senoid_wave(freq, duration, 800)

    square_header = generate_riff_header(length(square_wave))
    triangle_header = generate_riff_header(length(triangle_wave))
    senoid_header = generate_riff_header(length(senoid_wave))

    write_wav_file(output_prefix * "_square.wav", square_header, square_wave)
    write_wav_file(output_prefix * "_triangle.wav", triangle_header, triangle_wave)
    write_wav_file(output_prefix * "_senoid.wav", senoid_header, senoid_wave)

    println("Generated files:")
    println("  - $(output_prefix)_square.wav (Square wave)")
    println("  - $(output_prefix)_triangle.wav (Triangle wave)")
    println("  - $(output_prefix)_senoid.wav (Sine wave)")

end

"""
    main()

    Entry point for the script.
    Iterates over all MIDI files in the 'midi-samples' directory and generates WAV files.
"""
function main()

    project_dir = abspath(joinpath(dirname(@__FILE__), "..", "..", ".."))
    midi_dir = joinpath(project_dir, "midi-samples")

    if !isdir(midi_dir)

        error("MIDI samples directory '$midi_dir' not found.")

    end

    for file in readdir(midi_dir, join=true)

        if endswith(file, ".mid")

            output_file = replace(file[1:end-4], "midi" => "wave")

            process_midi_note(file, output_file)

        end

    end
    
end

main()

end  # module generateWave