From: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Fri, 14 Jul 2017 16:03:39 -0400
Message-ID: <1500062619.3583.71.camel@linux.vnet.ibm.com>
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
	<1500058362.2853.28.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1500058362.2853.28.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, "Serge E.
	Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

T24gRnJpLCAyMDE3LTA3LTE0IGF0IDExOjUyIC0wNzAwLCBKYW1lcyBCb3R0b21sZXkgd3JvdGU6
Cj4gT24gRnJpLCAyMDE3LTA3LTE0IGF0IDE0OjQ4IC0wNDAwLCBNaW1pIFpvaGFyIHdyb3RlOgo+
ID4gVGhlIGNvbmNlcm4gaXMgd2l0aCBhIHNoYXJlZCBmaWxlc3lzdGVtcy4gwqBJbiB0aGF0IGNh
c2UsIGZvciBJTUEgaXQKPiA+IHdvdWxkIG1ha2Ugc2Vuc2UgdG8gc3VwcG9ydCBhIG5hdGl2ZSBh
bmQgYSBuYW1lc3BhY2UgeGF0dHIuIMKgSWYgZHVlCj4gPiB0byB4YXR0ciBzcGFjZSBsaW1pdGF0
aW9ucyB3ZSBoYXZlIHRvIGxpbWl0IHRoZSBudW1iZXIgb2YgeGF0dHJzLAo+ID4gdGhlbiB3ZSBz
aG91bGQgbGltaXQgaXQgdG8gdHdvIC0gYSBuYXRpdmUgYW5kIGEgbmFtZXNwYWNlIHZlcnNpb24s
Cj4gPiB3aXRoIGEgInVpZD0iIHRhZyAtIGZpcnN0IG5hbWVzcGFjZSBnZXRzIHBlcm1pc3Npb24g
dG8gd3JpdGUgdGhlCj4gPiBuYW1lc3BhY2UgeGF0dHIuIMKgQWdhaW4sIGxpa2UgaW4gdGhlIGxh
eWVyZWQgY2FzZSwgaWYgdGhlIG5hbWVzcGFjZQo+ID4geGF0dHIgZG9lc24ndCBleGlzdCwgZmFs
bCBiYWNrIHRvIHVzaW5nIHRoZSBuYXRpdmUgeGF0dHIuCj4gCj4gSnVzdCBvbiB0aGlzIHBvaW50
OiBpZiB3ZSdyZSByZWFsbHkgY29uY2VybmVkIGFib3V0IHRoZSBuZWVkIG9uIHNoYXJlZAo+IGZp
bGVzeXN0ZW1zIHRvIGhhdmUgbXVsdGlwbGUgSU1BIHNpZ25hdHVyZXMgcGVyIGZpbGUsIG1pZ2h0
IGl0IG5vdCBtYWtlCj4gc2Vuc2Ugc2ltcGx5IHRvIHN1cHBvcnQgbXVsdGlwbGUgc2lnbmF0dXJl
cyB3aXRoaW4gdGhlIHNlY3VyaXR5LmltYQo+IHhhdHRyPyBUaGUgcnVsZXMgZm9yIHdyaXRpbmcg
c2lnbmF0dXJlIHVwZGF0ZXMgd2l0aGluIHVzZXIgbmFtZXNwYWNlcwo+IHdvdWxkIGJlIHNvbWV3
aGF0IGNvbXBsZXggKHNheSBvbmx5IGFibGUgdG8gcmVwbGFjZSBhIHNpZ25hdHVyZSBmb3IKPiB3
aGljaCB5b3UgZGVtb25zdHJhdGUgeW91IHBvc3Nlc3MgdGhlIGtleSkgYnV0IGl0IHdvdWxkIGxl
YWQgdG8gYW4KPiBpbXBsZW1lbnRhdGlvbiB3aGljaCB3b3VsZCB3b3JrIGZvciB0cmFkaXRpb25h
bCBzaGFyZWQgZmlsZXN5c3RlbXMKPiAobGlrZSBORlMpIGFzIHdlbGwgYXMgY29udGFpbmVyaXNl
ZCBiaW5kIG1vdW50cy4KCldyaXRpbmcgc2VjdXJpdHkuaW1hIHJlcXVpcmVzIGJlaW5nIHJvb3Qg
d2l0aCBDQVBfU1lTX0FETUlOCnByaXZpbGVnZXMuIMKgSSB3b3VsZG4ndCB3YW50IHRvIGdpdmUg
cm9vdCB3aXRoaW4gdGhlIG5hbWVzcGFjZQpwZXJtaXNzaW9uIHRvIG92ZXIgd3JpdGUgb3IganVz
dCBleHRlbmQgdGhlIG5hdGl2ZSBzZWN1cml0eS5pbWEuCgpNaW1pCgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApD
b250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhm
b3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
