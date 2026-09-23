build:
	@scripts/build.sh -p production

release:
	@scripts/release.sh

size:
	@scripts/check-sizes.sh

test:
	@scripts/test.sh -p default

# GovernorTimelock, its interface and Interfaces.sol are deliberately left as they
# are; everything else under contracts/, plus all tests, is formatted. The wildcard
# means a new contract is picked up automatically.
FMT_EXCLUDE = contracts/GovernorTimelock.sol contracts/interfaces/IGovernorTimelock.sol contracts/interfaces/Interfaces.sol
FMT_PATHS   = $(filter-out $(FMT_EXCLUDE),$(wildcard contracts/*.sol) $(wildcard contracts/interfaces/*.sol)) tests

format:
	@node scripts/align_fmt.js $(FMT_PATHS)

check-format:
	@node scripts/align_fmt.js --check $(FMT_PATHS)
