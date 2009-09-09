From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v5][PATCH 8/8]: Define clone_with_pids() syscall
Date: Wed, 9 Sep 2009 11:03:03 -0700
Message-ID: <20090909180303.GA21048__38404.5162740678$1252519253$gmane$org@us.ibm.com>
References: <20090907211302.GA5892@us.ibm.com>
	<20090907211700.GH6685@us.ibm.com> <m3zl95l2oz.fsf@pobox.com>
	<200909091419.50496.arnd@arndb.de> <4AA7CF1F.3020408@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AA7CF1F.3020408-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

H. Peter Anvin [hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org] wrote:
| On 09/09/2009 05:19 AM, Arnd Bergmann wrote:
| > 
| > This is a complex problem. The structure above would need a conversion
| > for the pointer size that you can avoid by using a u64, but that introduces
| > another problem:
| > 
| > 2. use a single pointer, with variable length data structures:
| > 
| > struct pid_set {
| > 	int num_pids;
| > 	pid_t pids[0];
| > };
| > 
| > Since pid_t is always an int, you have no problem with padding or
| > incompatible types, but rely on a data structure definition that
| > is not in C89 (not sure about C99).

C90 or C99 below should work. Is it ok to use a data structure that is
not in C89 ? 

BTW, would it work if we defined 

	struct pid_set {
		u64 pids;
		int num_pids;
	}

where ->pids can be still be a pointer ? The data structure would
have the same size on all architectures.

Thanks for the input

Sukadev
