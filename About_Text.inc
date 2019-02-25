; *****************
; *** About text ***
; *****************

.data
	SiteNum					equ 		39		; Number of sides to be shown.
											; You can add more sites of course, BUT TO PREVENT CRASHING :
											; - 7 Lines per site !!!
											; - No empty strings like "" !!!
											; - Last byte of last site must be 0FFh !!!
	AboutLoop				BOOL	FALSE	; TRUE=Loop About_Slider
											; FALSE=Leave About_Slider after showing all sites
;
	ScrTxt1Delay				db	4			; TimeDelay in millsecs = Value * 32	-> 2*32=64 milliseconds this side is shown
	ScrTxt1					db     32,0,32,0,32,0,"            OH, NOEEES... :O",0,32,0,32,0,32,0
;
	ScrTxt2					db	4,32,0,32,0,32,0,"        HIDE, SERIALS, HIDE !!!!",0,32,0,32,0,32,0
;
	ScrTxt3					db	4,32,0,32,0,32,0," THE KEY-PWNER'S IN THE HOUSE...",0,32,0,32,0,32,0
;
	ScrTxt4_Delay				db	5
;	ScrTxt4_1					db      "            ****              ****",0
;	ScrTxt4_2					db      "           *                   *   *",0
;	ScrTxt4_3					db      "            ****     ***      *   *",0
;	ScrTxt4_4					db      "                *     *  *     *   *",0
;	ScrTxt4_5					db      "           ****      *  *     ****",0
;	ScrTxt4_6					db      " ",0
	ScrTxt4_7					db      "           PROUDLY PRESENTS",0
;	
	ScrTxt5					db	6," ",0," ",0,"            XXXXXXXXXXX vX.X",0," ",0,"             Keygenned by MiSSiNG iN ByTES",0," ",0," ",0
;	
	ScrTxt6_Delay				db	6
	ScrTxt6_1					db      "*****************************************",0
	ScrTxt6_2					db      " ",0
	ScrTxt6_3					db      "        Celebrating RSA-1024 reverse",0
	ScrTxt6_4					db      " ",0
	ScrTxt6_5					db      "       Check out  missinginbytes.hit.bg",0
	ScrTxt6_6					db      " ",0
	ScrTxt6_7					db      "*****************************************",0
;	
	ScrTxt7					db	5," ",0,"               GFX :  MiB",0," ",0,"             Intro : MiB",0," ",0," ",0," ",0
;	
	ScrTxt8_Delay				db	4
	ScrTxt8_1					db      "       .                       .",0
	ScrTxt8_2					db      "   .        .      .                     .",0
	ScrTxt8_3					db      "           .          .                 .   .",0
	ScrTxt8_4					db      "   .          GREETINGS TO:    .",0
	ScrTxt8_5					db      ".            .   .                .           .",0
	ScrTxt8_6					db      "       .           .                 .",0
	ScrTxt8_7					db      "            .             .       .",0
;
	ScrTxt9					db	2,32,0,32,0,32,0,"                 +NCR/CRC!",0,32,0,32,0,32,0
	ScrTxt10					db	2,32,0,32,0,32,0,"                  3ck5u6",0,32,0,32,0,32,0
	ScrTxt11					db	2,32,0,32,0,32,0,"                 Al-Kaiser",0,32,0,32,0,32,0
	ScrTxt12					db	2,32,0,32,0,32,0,"                  ALiEN",0,32,0,32,0,32,0
	ScrTxt13					db	2,32,0,32,0,32,0,"                 Apocalyps",0,32,0,32,0,32,0
	ScrTxt14					db	2,32,0,32,0,32,0,"                Bone Enterprise",0,32,0,32,0,32,0
	ScrTxt15					db	2,32,0,32,0,32,0,"                  BytePtr",0,32,0,32,0,32,0
	ScrTxt16					db	2,32,0,32,0,32,0,"                  Ecliptic",0,32,0,32,0,32,0
	ScrTxt17					db	2,32,0,32,0,32,0,"                  Fungus",0,32,0,32,0,32,0
	ScrTxt18					db	2,32,0,32,0,32,0,"                   Hawk",0,32,0,32,0,32,0
	ScrTxt19					db	2,32,0,32,0,32,0,"                 Jada^AoC",0,32,0,32,0,32,0
	ScrTxt20					db	2,32,0,32,0,32,0,"                 kittmaster",0,32,0,32,0,32,0
	ScrTxt21					db	2,32,0,32,0,32,0,"                  Killboy",0,32,0,32,0,32,0
	ScrTxt22					db	2,32,0,32,0,32,0,"                 Lena151",0,32,0,32,0,32,0
	ScrTxt23					db	2,32,0,32,0,32,0,"                    LibX",0,32,0,32,0,32,0
	ScrTxt24					db	2,32,0,32,0,32,0,"                    Loki",0,32,0,32,0,32,0
	ScrTxt25					db	2,32,0,32,0,32,0,"                    LoL",0,32,0,32,0,32,0
	ScrTxt26					db	2,32,0,32,0,32,0,"                MaRKuS TH-DJM",0,32,0,32,0,32,0
	ScrTxt27					db	2,32,0,32,0,32,0,"                 MiTEstARK",0,32,0,32,0,32,0
	ScrTxt28					db	2,32,0,32,0,32,0,"                  PakMan",0,32,0,32,0,32,0
	ScrTxt29					db	2,32,0,32,0,32,0,"                PuNk!DuDe",0,32,0,32,0,32,0
	ScrTxt30					db	2,32,0,32,0,32,0,"                  Sonny27",0,32,0,32,0,32,0
	ScrTxt31					db	2,32,0,32,0,32,0,"                SuperCracker",0,32,0,32,0,32,0
	ScrTxt32					db	2,32,0,32,0,32,0,"                  syk071c",0,32,0,32,0,32,0
	ScrTxt33					db	2,32,0,32,0,32,0,"                Teddy Rogers",0,32,0,32,0,32,0
	ScrTxt34					db	2,32,0,32,0,32,0,"                The Riddler",0,32,0,32,0,32,0
	ScrTxt35					db	2,32,0,32,0,32,0,"                    willie",0,32,0,32,0,32,0
	ScrTxt36					db	2,32,0,32,0,32,0,"                     Xes",0,32,0,32,0,32,0
	ScrTxt37					db	2,32,0,32,0,32,0,"                 Zer0Burn",0,32,0,32,0,32,0
	ScrTxt38					db	2,32,0,32,0,32,0,"                   Ziggy",0,32,0,32,0,32,0
;	
	ScrTxt39					db	4," ",0,"               That's  all !",0," ",0,"                Cya.... :P",0," ",0," ",0," ",0
;
	ScrEND					db	0FFh      ; FF = End

.data?
	ScrSitePtrBuffer			dd	7 * SiteNum dup (?)   ; This must not be changed !!