//nolint
package app

import (
	"io"

	"github.com/evdatsion/aphelion-staking/libs/log"
	dbm "github.com/evdatsion/tm-db"

	"github.com/evdatsion/cusp-sdk/baseapp"
	sdk "github.com/evdatsion/cusp-sdk/types"
	"github.com/evdatsion/cusp-sdk/x/staking"
)

var (
	genesisFile        string
	paramsFile         string
	exportParamsPath   string
	exportParamsHeight int
	exportStatePath    string
	exportStatsPath    string
	seed               int64
	initialBlockHeight int
	numBlocks          int
	blockSize          int
	enabled            bool
	verbose            bool
	lean               bool
	commit             bool
	period             int
	onOperation        bool // TODO Remove in favor of binary search for invariant violation
	allInvariants      bool
	genesisTime        int64
)

// DONTCOVER

// NewCuspAppUNSAFE is used for debugging purposes only.
//
// NOTE: to not use this function with non-test code
func NewCuspAppUNSAFE(logger log.Logger, db dbm.DB, traceStore io.Writer, loadLatest bool,
	invCheckPeriod uint, baseAppOptions ...func(*baseapp.BaseApp),
) (gapp *CuspApp, keyMain, keyStaking *sdk.KVStoreKey, stakingKeeper staking.Keeper) {

	gapp = NewCuspApp(logger, db, traceStore, loadLatest, invCheckPeriod, baseAppOptions...)
	return gapp, gapp.keys[baseapp.MainStoreKey], gapp.keys[staking.StoreKey], gapp.stakingKeeper
}
