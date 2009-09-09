From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC][v5][PATCH 8/8]: Define clone_with_pids() syscall
Date: Wed, 9 Sep 2009 11:34:22 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0909091129400.7458__27774.5972540744$1252521417$gmane$org@localhost.localdomain>
References: <20090907211302.GA5892@us.ibm.com>
	<20090907211700.GH6685@us.ibm.com> <m3zl95l2oz.fsf@pobox.com>
	<200909091419.50496.arnd@arndb.de> <4AA7CF1F.3020408@zytor.com>
	<20090909180303.GA21048@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090909180303.GA21048-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



On Wed, 9 Sep 2009, Sukadev Bhattiprolu wrote:
> 
> BTW, would it work if we defined 
> 
> 	struct pid_set {
> 		u64 pids;
> 		int num_pids;
> 	}
> 
> where ->pids can be still be a pointer ? The data structure would
> have the same size on all architectures.

I don't think that's all that great. Just go with the C90 version, we 
already have that thing in the kernel, and

	struct pid_set {
		int num_pids;
		pid_t pids[];
	};

looks simple and straightforward. And it even makes your example simpler, 
doesn't it? Ie now it's just

	struct pid_set pids = { 3, { 0, 97, 99 } };

and gcc should do the right thing.

(Of course, in any real case it would be dynamically allocated, but 
whatever).

		Linus
