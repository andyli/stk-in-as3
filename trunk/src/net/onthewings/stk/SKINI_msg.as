/*********************************************************/
/*
  Definition of SKINI Message Types and Special Symbols
     Synthesis toolKit Instrument Network Interface

  These symbols should have the form:

   \c __SK_<name>_

  where <name> is the string used in the SKINI stream.

  by Perry R. Cook, 1995 - 2004.
*/
/*********************************************************/

internal const NOPE:int =						-32767;
internal const YEP:int =						1;
internal const SK_DBL:int =						-32766;
internal const SK_INT:int =						-32765;
internal const SK_STR:int =						-32764;
internal const __SK_Exit_:int =					999;

/***** MIDI COMPATIBLE MESSAGES *****/
/*** (Status bytes for channel=0) ***/

internal const __SK_NoteOff_:int =					28;
internal const __SK_NoteOn_:int =					144;
internal const __SK_PolyPressure_:int =				160;
internal const __SK_ControlChange_:int =			176;
internal const __SK_ProgramChange_:int =			192;
internal const __SK_AfterTouch_:int =				208;
internal const __SK_ChannelPressure_:int =			__SK_AfterTouch_;
internal const __SK_PitchWheel_:int =				224;
internal const __SK_PitchBend_:int =				__SK_PitchWheel_;
internal const __SK_PitchChange_:int =				49;

internal const __SK_Clock_:int =					248;
internal const __SK_SongStart_:int =				250;
internal const __SK_Continue_:int =					251;
internal const __SK_SongStop_:int =					252;
internal const __SK_ActiveSensing_:int =			254;
internal const __SK_SystemReset_:int =				255;

internal const __SK_Volume_:int =					7;
internal const __SK_ModWheel_:int =					1;
internal const __SK_Modulation_:int =				__SK_ModWheel_;
internal const __SK_Breath_:int =					2;
internal const __SK_FootControl_:int =				4;
internal const __SK_Portamento_:int =				65;
internal const __SK_Balance_:int =					8;
internal const __SK_Pan_:int =						10;
internal const __SK_Sustain_:int =					64;
internal const __SK_Damper_:int =					__SK_Sustain_;
internal const __SK_Expression_:int =				11; 

internal const __SK_AfterTouch_Cont_:int =			128;
internal const __SK_ModFrequency_:int =				__SK_Expression_;

internal const __SK_ProphesyRibbon_:int =			16;
internal const __SK_ProphesyWheelUp_:int =			2;
internal const __SK_ProphesyWheelDown_:int =		3;
internal const __SK_ProphesyPedal_:int =			18;
internal const __SK_ProphesyKnob1_:int =			21;
internal const __SK_ProphesyKnob2_:int =			22;

/***  Instrument Family Specific ***/

internal const __SK_NoiseLevel_:int =				__SK_FootControl_;

internal const __SK_PickPosition_:int =				__SK_FootControl_;
internal const __SK_StringDamping_:int =			__SK_Expression_;
internal const __SK_StringDetune_:int =				__SK_ModWheel_;
internal const __SK_BodySize_:int =					__SK_Breath_;
internal const __SK_BowPressure_:int =				__SK_Breath_;
internal const __SK_BowPosition_:int =				__SK_PickPosition_;
internal const __SK_BowBeta_:int =					__SK_BowPosition_;

internal const __SK_ReedStiffness_:int =			__SK_Breath_;
internal const __SK_ReedRestPos_:int =				__SK_FootControl_;

internal const __SK_FluteEmbouchure_:int =			__SK_Breath_;
internal const __SK_JetDelay_:int =					__SK_FluteEmbouchure_;

internal const __SK_LipTension_:int =				__SK_Breath_;
internal const __SK_SlideLength_:int =				__SK_FootControl_;

internal const __SK_StrikePosition_:int =			__SK_PickPosition_;
internal const __SK_StickHardness_:int =			__SK_Breath_;

internal const __SK_TrillDepth_:int =				1051;
internal const __SK_TrillSpeed_:int =				1052;
internal const __SK_StrumSpeed_:int =				__SK_TrillSpeed_;
internal const __SK_RollSpeed_:int =				__SK_TrillSpeed_;

internal const __SK_FilterQ_:int =					__SK_Breath_;
internal const __SK_FilterFreq_:int =				1062;
internal const __SK_FilterSweepRate_:int =			__SK_FootControl_;

internal const __SK_ShakerInst_:int =				1071;
internal const __SK_ShakerEnergy_:int =				__SK_Breath_;
internal const __SK_ShakerDamping_:int =			__SK_ModFrequency_;
internal const __SK_ShakerNumObjects_:int =			__SK_FootControl_;

internal const __SK_Strumming_:int =				1090;
internal const __SK_NotStrumming_:int =				1091;
internal const __SK_Trilling_:int =					1092;
internal const __SK_NotTrilling_:int =				1093;
internal const __SK_Rolling_:int =					__SK_Strumming_;
internal const __SK_NotRolling_:int =				__SK_NotStrumming_;

internal const __SK_PlayerSkill_:int =				2001;
internal const __SK_Chord_:int =					2002;
internal const __SK_ChordOff_:int =        			2003;

internal const __SK_SINGER_FilePath_:int =			3000;
internal const __SK_SINGER_Frequency_:int =			3001;
internal const __SK_SINGER_NoteName_:int =			3002;
internal const __SK_SINGER_Shape_:int =				3003;
internal const __SK_SINGER_Glot_:int =				3004;
internal const __SK_SINGER_VoicedUnVoiced_:int =	3005;
internal const __SK_SINGER_Synthesize_:int =		3006;
internal const __SK_SINGER_Silence_:int =			3007;
internal const __SK_SINGER_VibratoAmt_:int =		__SK_ModWheel_;
internal const __SK_SINGER_RndVibAmt_:int =			3008;
internal const __SK_SINGER_VibFreq_:int =			__SK_Expression_;