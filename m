From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Thu, 31 May 2012 16:55:31 +0800
Message-ID: <4FC73203.2070009__2282.06548276848$1338454506$gmane$org@cn.fujitsu.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
	<4FC6B68C.2070703@jp.fujitsu.com>
	<CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com>
	<4FC6BC3E.5010807@jp.fujitsu.com>
	<alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com>
	<4FC6C111.2060108@jp.fujitsu.com>
	<alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com>
	<4FC6D881.4090706@jp.fujitsu.com>
	<alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com>
	<4FC70355.70805@jp.fujitsu.com>
	<alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com>
	<4FC70E5E.1010003@gmail.com>
	<alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com>
	<4FC711A5.4090003@gmail.com>
	<alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com>
	<CAHGf_=qVDVT6VW2j9gE3bQKwizW24iivrDryiCKoxVu4m_fWKw@mail.gmail.com>
	<alpine.DEB.2.00.1205310028420.8864@chino.kir.corp.google.com>
	<4FC720EE.3010307@gmail.com> <4FC724B1.70508@cn.fujitsu.com>
	<4FC72CA4.6080708@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4FC72CA4.6080708-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, KOSAKI Motohiro <kosaki.motohiro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

5LqOIDIwMTLlubQwNeaciDMx5pelIDE2OjMyLCBHbGF1YmVyIENvc3RhIOWGmemBkzoKPiBPbiAw
NS8zMS8yMDEyIDExOjU4IEFNLCBHYW8gZmVuZyB3cm90ZToKPj4+ID4gIEl0J3Mgb25lIG9mIGEg
b3B0aW9uLiBCdXQsIEkgc2VyaW91c2x5IGRvdWJ0IGZ1c2UgY2FuIG1ha2Ugc2ltcGxlciB0aGFu
IGthbWV6YXdhLXNhbidzCj4+PiA+ICBpZGVhLiBCdXQgeWVhaCwgSSBtaWdodCBOQUNLIGthbWV6
YXdhLXNhbidzIG9uZSBpZiBoZSB3aWxsIHBvc3QgdWdseSBwYXRjaC4KPj4+ID4KPj4gSXQgc2Vh
bXMgSSBzaG91bGQgZG8gc29tZSBob21ld29yayB0byBtYWtlIHRoZSBpbXBsZW1lbnQgYmVhdXRp
ZnVsbHkuCj4+Cj4+IEkgdGhpbmsga2FtZXphd2Etc2FuJ3MgaWRlYSBpcyBtb3JlIHNpbXBsZXIu
Cj4+IHRoYW5rcyBmb3IgeW91ciBhZHZpY2UuCj4+Cj4gCj4gT25lIHRoaW5rIHRvIGtlZXAgaW4g
bWluZDogQSBmaWxlIGluIG1lbWNnIGRvZXMgbm90IG5lZWQgdG8gZm9sbG93IHRoZSBzYW1lIGZv
cm1hdCBvZiAvcHJvYy9tZW1pbmZvIHNvIHdlIGNhbiBiaW5kIG1vdW50LiBXZSBzaG91bGQgYmUg
YWJsZSB0byByZWNvbnN0cnVjdCB0aGF0IGluIHVzZXJzcGFjZSBiYXNlZCBvbiBpbmZvcm1hdGlv
bgo+IGF2YWlsYWJsZSBmcm9tIHRoZSBrZXJuZWwuIFlvdSBjYW4gZXZlbiBjb2xsZWN0IHRoYXQg
ZnJvbSBtdWx0aXBsZSBsb2NhdGlvbnMsIGFuZCAqdGhlbiogeW91IGJpbmQgbW91bnQuCj4gCj4g
SXQgaGVscHMgdG8ga2VlcCB0aGUgY2h1cm4gb3V0IG9mIHRoZSBrZXJuZWwsIGFuZCBpbiBjYXNl
IG9mIG1lbWluZm8sIHlvdSBtaWdodCBuZWVkIG5vIGV4dHJhIGtlcm5lbCBwYXRjaGVzIGF0IGFs
bC4gQW5kIGluIHRoZSBjYXNlIG9mIG90aGVyIGZpbGVzIGxpa2UgL3Byb2Mvc3RhdCwgdGhlIHJl
bGV2YW50IGluZm9ybWF0aW9uIGNvbWVzIGZyb20KPiBtb3JlIHRoYW4gb25lIGNncm91cCBhbnl3
YXksIHNvIHRoZXJlIGlzIG5vdCB0b28gbXVjaCB3YXkgYXJvdW5kIGl0LgoKSSBnb3QgaXQsdGhh
bmsgeW91IHZlcnkgbXVjaCxpbmRlZWQgd2UgbmVlZCBubyBleHRyYSBrZXJuZWwgcGF0Y2ggYXQg
YWxsLgpNYXliZSB3ZSBzaG91bGQgZG8gdGhpcyB3b3JrIGluIGx4YyBvciBsaWJ2aXJ0LgoKdGhh
bmtzIEdsYXViZXIhCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRh
dGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGlu
Zm8vY29udGFpbmVycw==
