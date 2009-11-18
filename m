From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] user-cr: fix uninitialized use in shmem test
Date: Tue, 17 Nov 2009 18:04:27 -0600
Message-ID: <1258502667.4031.1206.camel@localhost.localdomain>
References: <4B01B56A.8050106@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B01B56A.8050106-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

V2l0aCBja3B0LXYxOS1yYzEgYnJhbmNoIGluIHVzZXItY3IgSSBnZXQ6CgpzaG1lbS5jOiBJbiBm
dW5jdGlvbiDigJhtYWlu4oCZOgpzaG1lbS5jOjUzOiB3YXJuaW5nOiDigJhh4oCZIG1heSBiZSB1
c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5jdGlvbgoKU2lnbmVkLW9mZi1ieTogTmF0aGFu
IEx5bmNoIDxudGxAcG9ib3guY29tPgotLS0KIHRlc3Qvc2htZW0uYyB8ICAgIDIgKy0KIDEgZmls
ZXMgY2hhbmdlZCwgMSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBh
L3Rlc3Qvc2htZW0uYyBiL3Rlc3Qvc2htZW0uYwppbmRleCBkODkyYTI1Li42ZDdkZDhhIDEwMDY0
NAotLS0gYS90ZXN0L3NobWVtLmMKKysrIGIvdGVzdC9zaG1lbS5jCkBAIC0xMSw3ICsxMSw3IEBA
IGludCBtYWluKGludCBhcmdjLCBjaGFyICphcmd2W10pCiB7CiAJRklMRSAqZmlsZTsKIAlpbnQg
KmFkZHI7Ci0JZmxvYXQgYTsKKwlmbG9hdCBhID0gMDsKIAlwaWRfdCBwaWQ7CiAJaW50IHBpcGVm
ZFsyXTsKIAlpbnQgaSwgcmV0OwotLSAKMS42LjIuNQoKCgpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWlu
ZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgtZm91bmRh
dGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
