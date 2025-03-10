TiffanyPhoneScript1:
	gettrainername PICNICKER, TIFFANY1, STRING_BUFFER_3
	checkflag ENGINE_TIFFANY_READY_FOR_REMATCH
	iftruefwd .WantsBattle
	farscall PhoneScript_AnswerPhone_Female
	checkflag ENGINE_TIFFANY_TUESDAY_AFTERNOON
	iftruefwd .NotTuesday
	checkflag ENGINE_TIFFANY_HAS_PINK_BOW
	iftruefwd .HasItem
	readvar VAR_WEEKDAY
	ifnotequal TUESDAY, .NotTuesday
	checktime 1 << DAY
	iftruefwd TiffanyTuesdayAfternoon

.NotTuesday:
	farsjump TiffanyNoItemScript

.WantsBattle:
	getlandmarkname ROUTE_43, STRING_BUFFER_5
	farsjump TiffanyAsleepScript

.HasItem:
	getlandmarkname ROUTE_43, STRING_BUFFER_5
	farsjump TiffanyHurryScript

TiffanyPhoneScript2:
	gettrainername PICNICKER, TIFFANY1, STRING_BUFFER_3
	farscall PhoneScript_Random4
	ifequalfwd $0, TiffanysFamilyMembers
	farscall PhoneScript_GreetPhone_Female
	checkflag ENGINE_TIFFANY_READY_FOR_REMATCH
	iftruefwd .Generic
	checkflag ENGINE_TIFFANY_TUESDAY_AFTERNOON
	iftruefwd .Generic
	checkflag ENGINE_TIFFANY_HAS_PINK_BOW
	iftruefwd .Generic
	farscall PhoneScript_Random3
	ifequalfwd $0, TiffanyWantsBattle
	checkevent EVENT_TIFFANY_GAVE_PINK_BOW
	iftruefwd .PinkBow
	farscall PhoneScript_Random2
	ifequalfwd $0, TiffanyHasPinkBow

.PinkBow:
	farscall PhoneScript_Random11
	ifequalfwd $0, TiffanyHasPinkBow

.Generic:
	farsjump Phone_GenericCall_Female

TiffanyTuesdayAfternoon:
	setflag ENGINE_TIFFANY_TUESDAY_AFTERNOON

TiffanyWantsBattle:
	getlandmarkname ROUTE_43, STRING_BUFFER_5
	setflag ENGINE_TIFFANY_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Female

TiffanysFamilyMembers:
	random $6
	ifequalfwd $0, .Grandma
	ifequalfwd $1, .Grandpa
	ifequalfwd $2, .Mom
	ifequalfwd $3, .Dad
	ifequalfwd $4, .Sister
	ifequalfwd $5, .Brother

.Grandma:
	getstring Phone_GrandmaString, STRING_BUFFER_4
	sjumpfwd .PoorClefairy

.Grandpa:
	getstring Phone_GrandpaString, STRING_BUFFER_4
	sjumpfwd .PoorClefairy

.Mom:
	getstring Phone_MomString, STRING_BUFFER_4
	sjumpfwd .PoorClefairy

.Dad:
	getstring Phone_DadString, STRING_BUFFER_4
	sjumpfwd .PoorClefairy

.Sister:
	getstring Phone_SisterString, STRING_BUFFER_4
	sjumpfwd .PoorClefairy

.Brother:
	getstring Phone_BrotherString, STRING_BUFFER_4
	; fallthrough

.PoorClefairy:
	farsjump TiffanyItsAwful

TiffanyHasPinkBow:
	setflag ENGINE_TIFFANY_HAS_PINK_BOW
	getlandmarkname ROUTE_43, STRING_BUFFER_5
	farsjump PhoneScript_FoundItem_Female
