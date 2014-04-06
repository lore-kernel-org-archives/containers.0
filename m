From: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Subject: Re: [GIT PULL] cgroup changes for v3.15-rc1
Date: Sun, 6 Apr 2014 16:31:58 +0200
Message-ID: <20140406143158.GA14380__30170.9136496813$1396795136$gmane$org@x4>
References: <20140403164911.GE24119@htj.dyndns.org>
	<CA+55aFyGz2q4iDEt56Bw+x_ri_-DQYLAKPJvk3Uxj9z-y+0uPw@mail.gmail.com>
	<CA+55aFy+Jt0B32kj=Ldz9Krp4DXcXSP4r-o3f-2LPcVs4udGVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFy+Jt0B32kj=Ldz9Krp4DXcXSP4r-o3f-2LPcVs4udGVA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2014.04.04 at 18:11 -0700, Linus Torvalds wrote:
> On Fri, Apr 4, 2014 at 6:06 PM, Linus Torvalds
> <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> >
> > Will report back soon when I've narrowed it down more.
> 
> Ok, that may end up being harder than it looked. Commit
> a755180bab81c038a6989d7ab746c702f1b3ec03 doesn't boot for me at all,
> so apparently there are some really broken points in that whole
> development chain.

FWIW I've seen similar boot failures, that started during this merge
window, on my machine. I first thought they might be linker related so I
opened a bug on: https://sourceware.org/bugzilla/show_bug.cgi?id=16788
But if I remove e.g. a single printk the bug goes away...
Unfortunately the same thing happens if I enable more debugging options,
so I haven't tracked the issue down yet.

-- 
Markus
