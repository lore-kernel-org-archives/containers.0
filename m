From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] user-cr: fix uninitialized use in shmem test
Date: Wed, 25 Nov 2009 13:36:43 -0500
Message-ID: <4B0D793B.5050000@cs.columbia.edu>
References: <4B01B56A.8050106@cs.columbia.edu>
	<1258502667.4031.1206.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258502667.4031.1206.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

ClF1ZXVlZCBmb3IgdjE5LXJjMi4KCk5hdGhhbiBMeW5jaCB3cm90ZToKPiBXaXRoIGNrcHQtdjE5
LXJjMSBicmFuY2ggaW4gdXNlci1jciBJIGdldDoKPiAKPiBzaG1lbS5jOiBJbiBmdW5jdGlvbiDi
gJhtYWlu4oCZOgo+IHNobWVtLmM6NTM6IHdhcm5pbmc6IOKAmGHigJkgbWF5IGJlIHVzZWQgdW5p
bml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0aW9uCj4gCj4gU2lnbmVkLW9mZi1ieTogTmF0aGFuIEx5
bmNoIDxudGxAcG9ib3guY29tPgo+IC0tLQo+ICB0ZXN0L3NobWVtLmMgfCAgICAyICstCj4gIDEg
ZmlsZXMgY2hhbmdlZCwgMSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQo+IAo+IGRpZmYg
LS1naXQgYS90ZXN0L3NobWVtLmMgYi90ZXN0L3NobWVtLmMKPiBpbmRleCBkODkyYTI1Li42ZDdk
ZDhhIDEwMDY0NAo+IC0tLSBhL3Rlc3Qvc2htZW0uYwo+ICsrKyBiL3Rlc3Qvc2htZW0uYwo+IEBA
IC0xMSw3ICsxMSw3IEBAIGludCBtYWluKGludCBhcmdjLCBjaGFyICphcmd2W10pCj4gIHsKPiAg
CUZJTEUgKmZpbGU7Cj4gIAlpbnQgKmFkZHI7Cj4gLQlmbG9hdCBhOwo+ICsJZmxvYXQgYSA9IDA7
Cj4gIAlwaWRfdCBwaWQ7Cj4gIAlpbnQgcGlwZWZkWzJdOwo+ICAJaW50IGksIHJldDsKX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWls
aW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xp
c3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
