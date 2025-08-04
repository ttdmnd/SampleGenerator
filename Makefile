###############################################################################
# Sample Generator Project - Makefile
#
# This Makefile orchestrates building, cleaning, and running Python and Julia
# environments for the Sample Generator project.
###############################################################################

# Project directories and variables
PY_PROJECT_DIR := src/generateNote
PY_VENV := $(PY_PROJECT_DIR)/.venv
GENERATE_WAVE_JULIA_PROJECT_DIR := src/generateWave

# Main targets
.PHONY: all success run clean-samples

# Default target: build everything and show success message
all: build-python build-julia build-check-wave build-play-wave build-play-midi success

# Include auxiliary Makefiles for build, clean, and test rules
include Makefile.build    # Build rules
include Makefile.clean    # Clean rules
include Makefile.tests    # Test rules

###############################################################################
# Utility targets
###############################################################################

# Success message after full build
success:
	@echo "*************************************************"
	@echo "=== All environments are set up successfully! ==="
	@echo "*************************************************"

# Clean all generated MIDI and WAVE samples
clean-samples:
	@echo "Cleaning sample directories..."
	rm -rf midi-samples/*
	rm -rf wave-samples/*
	@echo "Sample directories cleaned!"

###############################################################################
# Project execution
###############################################################################

# Run the full pipeline: build, clean samples, and generate outputs
run: all clean-samples
	@echo "Running the Sample Generator project..."
	@echo "Use 'make test' to run tests or 'make clean' to clean environments."

    # Generate MIDI files using Python
	$(PY_VENV)/bin/python3 $(PY_PROJECT_DIR)/src/generateNote/generateNote.py
	@echo "MIDI files generated successfully!"

    # Generate WAVE files using Julia
	@julia --project=$(GENERATE_WAVE_JULIA_PROJECT_DIR) $(GENERATE_WAVE_JULIA_PROJECT_DIR)/src/generateWave.jl
	@echo "Wave files generated successfully!"

	@echo "Project run complete! Check the 'midi-samples' and 'wave-samples' directories