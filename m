From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 04/54] General infrastructure for checkpoint
	restart
Date: Wed, 06 May 2009 16:57:25 -0400
Message-ID: <4A01F9B5.3040908@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-5-git-send-email-orenl@cs.columbia.edu>
	<20090506203955.GA6003@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090506203955.GA6003-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

CgoKU3VrYWRldiBCaGF0dGlwcm9sdSB3cm90ZToKPiBPcmVuIExhYWRhbiBbb3JlbmxAY3MuY29s
dW1iaWEuZWR1XSB3cm90ZToKPiB8ICsKPiB8ICsvKiAnY2twdF9kZWJ1Z19sZXZlbCcgY29udHJv
bHMgdGhlIHZlcmJvc2l0eSBsZXZlbCBvZiBjL3IgY29kZSAqLwo+IHwgKyNpZmRlZiBDT05GSUdf
Q0hFQ0tQT0lOVF9ERUJVRwo+IHwgKwo+IHwgKy8qIEZJWDogYWxsb3cgdG8gY2hhbmdlIGR1cmlu
ZyBydW50aW1lICovCj4gfCArdW5zaWduZWQgaW50IF9fcmVhZF9tb3N0bHkgY2twdF9kZWJ1Z19s
ZXZlbCA9IENLUFRfRERFRkFVTFQ7Cj4gfCArCj4gfCArc3RhdGljIF9faW5pdCBpbnQgY2twdF9k
ZWJ1Z19zZXR1cChjaGFyICpzKQo+IHwgK3sKPiB8ICsJY2twdF9kZWJ1Z19sZXZlbCA9IHN0cmlj
dF9zdHJ0b3VsKHMsIE5VTEwsIDApOwo+IHwgKwlyZXR1cm4gMDsKPiB8ICt9Cj4gCj4gTml0OiBJ
bnRlcmNoYW5nZSBOVUxMIGFuZCAwIHRvIHN1cHByZXNzIHRoaXMgPwo+IAo+IGNoZWNrcG9pbnQv
c3lzLmM6Mzg0OiB3YXJuaW5nOiBwYXNzaW5nIGFyZ3VtZW50IDIgb2Yg4oCYc3RyaWN0X3N0cnRv
dWzigJkKPiBtYWtlcyBpbnRlZ2VyIGZyb20gcG9pbnRlciB3aXRob3V0IGEgY2FzdAoKaGVoIC4u
IHRoaXMgd2FzIHdyb25nIHRvIGJlZ2luIHdpdGguIGZpeGVkIGluIGNrcHQtdjE1LgoKT3Jlbi4K
Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5l
cnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0
cHM6Ly9saXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5l
cnM=
