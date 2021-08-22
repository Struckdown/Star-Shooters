extends MarginContainer


export(String) var upgradeName
var curCost
export(int) var upgradeLevels = 5
export(int) var baseCost = 100
var upgradeLevel = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if upgradeName in UpgradeManager.upgrades:
		upgradeLevel = UpgradeManager.upgrades[upgradeName]["curLevel"]
	else:	# set up data
		UpgradeManager.upgrades[upgradeName] = {
			"curLevel":0,
			"maxLevel":upgradeLevels,
			"startingCost": baseCost,
		}
	curCost = getCost(upgradeLevel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func getCost(level):
	if upgradeLevel >= upgradeLevels:
		return "MAX"
	return 100*((level+1)*1.5)	#TODO come up with better formula


func _on_Button_button_up():
	var curGems = UpgradeManager.gems
	if str(curCost) == "MAX" or curCost > curGems:
		return	# TODO add error noise?
	curGems -= curCost
	UpgradeManager.setGems(curGems)
	upgradeLevel += 1
	$Button/ChangeLbl.text = "TODO???"
	$Button/CostLbl.text = "x" + str(getCost(upgradeLevel))
	#TODO update progress bar
	UpgradeManager.upgrades[upgradeName][upgradeLevel] = upgradeLevel
