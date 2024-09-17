#
# Source File List for BP
#
LIBBP_INCLUDED = YES

SRC_libbp := $(SRC)/libbp.c \
	$(SRC)/libbpP.c \
	$(SRC)/bei.c \
	$(SRC)/bcb.c \
	$(SRC)/bib.c \
	$(SRC)/pnb.c \
	$(SRC)/bpq.c \
	$(SRC)/meb.c \
	$(SRC)/bae.c \
	$(SRC)/hcb.c \
	$(SRC)/snw.c \
	$(SRC)/imc.c \
	$(SRC)/libimcfw.c \
	$(SRC)/bibe.c \
	$(SRC)/eureka.c \
	$(SRC)/saga.c \
	$(SRC)/bpsec_policy.c \
	$(SRC)/bpsec_instr.c \
	$(SRC)/bpsec_policy_eventset.c \
	$(SRC)/bpsec_policy_rule.c \
	$(SRC)/bpsec_util.c \
	$(SRC)/bpsec_policy_event.c \
	$(SRC)/bpsec_asb.c \
	$(SRC)/sci.c \
	$(SRC)/sc_value.c \
	$(SRC)/sci_valmap.c \
	$(SRC)/sc_util.c \
	$(SRC)/ion_test_sc.c \
	$(SRC)/bib_hmac_sha2_sc.c \
	$(SRC)/bcb_aes_gcm_sc.c \
	$(SRC)/rfc9173_utils.c 

# 9/13/2024
# Removed following from BPv6
# $(SRC)/profiles.c
# $(SRC)/bpsec.c