From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Fri, 14 Jul 2017 11:52:42 -0700
Message-ID: <1500058362.2853.28.camel__45022.5071436309$1500058385$gmane$org@HansenPartnership.com>
References: <87y3rscz9j.fsf@xmission.com>
	<20170713164012.brj2flnkaaks2oci@thunk.org>
	<87k23cb6os.fsf@xmission.com>
	<847ccb2a-30c0-a94c-df6f-091c8901eaa0@linux.vnet.ibm.com>
	<87bmoo8bxb.fsf@xmission.com>
	<9a3010e5-ca2b-5e7a-656b-fcc14f7bec4e@linux.vnet.ibm.com>
	<87h8yf7szd.fsf@xmission.com>
	<65dbe654-0d99-03fa-c838-5a726b462826@linux.vnet.ibm.com>
	<20170714133437.GA16737@mail.hallyn.com>
	<596f808b-e21d-8296-5fef-23c1ce7ab778@linux.vnet.ibm.com>
	<20170714173556.GA19669@mail.hallyn.com>
	<1500058090.3583.28.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1500058090.3583.28.camel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

T24gRnJpLCAyMDE3LTA3LTE0IGF0IDE0OjQ4IC0wNDAwLCBNaW1pIFpvaGFyIHdyb3RlOgo+IFRo
ZSBjb25jZXJuIGlzIHdpdGggYSBzaGFyZWQgZmlsZXN5c3RlbXMuIMKgSW4gdGhhdCBjYXNlLCBm
b3IgSU1BIGl0Cj4gd291bGQgbWFrZSBzZW5zZSB0byBzdXBwb3J0IGEgbmF0aXZlIGFuZCBhIG5h
bWVzcGFjZSB4YXR0ci4gwqBJZiBkdWUKPiB0byB4YXR0ciBzcGFjZSBsaW1pdGF0aW9ucyB3ZSBo
YXZlIHRvIGxpbWl0IHRoZSBudW1iZXIgb2YgeGF0dHJzLAo+IHRoZW4gd2Ugc2hvdWxkIGxpbWl0
IGl0IHRvIHR3byAtIGEgbmF0aXZlIGFuZCBhIG5hbWVzcGFjZSB2ZXJzaW9uLAo+IHdpdGggYSAi
dWlkPSIgdGFnIC0gZmlyc3QgbmFtZXNwYWNlIGdldHMgcGVybWlzc2lvbiB0byB3cml0ZSB0aGUK
PiBuYW1lc3BhY2UgeGF0dHIuIMKgQWdhaW4sIGxpa2UgaW4gdGhlIGxheWVyZWQgY2FzZSwgaWYg
dGhlIG5hbWVzcGFjZQo+IHhhdHRyIGRvZXNuJ3QgZXhpc3QsIGZhbGwgYmFjayB0byB1c2luZyB0
aGUgbmF0aXZlIHhhdHRyLgoKSnVzdCBvbiB0aGlzIHBvaW50OiBpZiB3ZSdyZSByZWFsbHkgY29u
Y2VybmVkIGFib3V0IHRoZSBuZWVkIG9uIHNoYXJlZApmaWxlc3lzdGVtcyB0byBoYXZlIG11bHRp
cGxlIElNQSBzaWduYXR1cmVzIHBlciBmaWxlLCBtaWdodCBpdCBub3QgbWFrZQpzZW5zZSBzaW1w
bHkgdG8gc3VwcG9ydCBtdWx0aXBsZSBzaWduYXR1cmVzIHdpdGhpbiB0aGUgc2VjdXJpdHkuaW1h
CnhhdHRyPyBUaGUgcnVsZXMgZm9yIHdyaXRpbmcgc2lnbmF0dXJlIHVwZGF0ZXMgd2l0aGluIHVz
ZXIgbmFtZXNwYWNlcwp3b3VsZCBiZSBzb21ld2hhdCBjb21wbGV4IChzYXkgb25seSBhYmxlIHRv
IHJlcGxhY2UgYSBzaWduYXR1cmUgZm9yCndoaWNoIHlvdSBkZW1vbnN0cmF0ZSB5b3UgcG9zc2Vz
cyB0aGUga2V5KSBidXQgaXQgd291bGQgbGVhZCB0byBhbgppbXBsZW1lbnRhdGlvbiB3aGljaCB3
b3VsZCB3b3JrIGZvciB0cmFkaXRpb25hbCBzaGFyZWQgZmlsZXN5c3RlbXMKKGxpa2UgTkZTKSBh
cyB3ZWxsIGFzIGNvbnRhaW5lcmlzZWQgYmluZCBtb3VudHMuCgpKYW1lcwoKX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxp
c3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxp
bnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
