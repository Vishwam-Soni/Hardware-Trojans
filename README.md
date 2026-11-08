# Hardware-Trojans
A comparative study of four Hardware Trojan variants in AES-128 cryptographic hardware, evaluating their detectability through physical design implementation, Power, Performance, and Area (PPA) metrics, and switching activity analysis using OpenLane and the SKY130 PDK.

## Overview
This research investigates the detectability of different Hardware Trojan variants in AES-128 cryptographic hardware. Four Trojan designs—Always-On, Simple Trigger, Rare Trigger, and Sequential Trigger; are compared against a Trojan-free golden design.

All five designs undergo an RTL-to-GDSII implementation flow using OpenLane, OpenROAD, and the SKY130 PDK. Their detectability is evaluated through Power, Performance, and Area (PPA) metrics, along with switching activity analysis.

The goal is to understand how different Trojan architectures affect physical design characteristics and how these changes can help identify potential hardware security threats.
