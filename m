From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 1/6] user namespace: make signal.c respect user
	namespaces (v4)
Date: Thu, 10 Nov 2011 08:27:24 -0600
Message-ID: <20111110142723.GA7727@sergelap>
References: <1320445482-8459-1-git-send-email-serge@hallyn.com>
	<1320445482-8459-2-git-send-email-serge@hallyn.com>
	<20111108162216.1ffb3e9a.akpm@linux-foundation.org>
	<20111109141853.GB4010@sergelap>
	<20111110014114.GB26567@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111110014114.GB26567-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Wed, Nov 09, 2011 at 08:18:53AM -0600, Serge E. Hallyn wrote:
> > Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> > > On Fri,  4 Nov 2011 22:24:37 +0000
> > > Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> > > 
> > > > +static inline void fixup_uid(struct siginfo *info, struct task_struct *t)
> 
> nit: Seems like the function name itself needs a fixup. I can imagine a
> user-ns-unaware kernel developer thinking this when they see code calling
> this function:
> 
> <naive>
> Gosh, why is the uid broken? I have no idea what this does or when it
> would be needed. Why hasn't it been splatted all over the kernel? Who broke
> it?
> </naive>
> 
> You can't even tell from the name that it's for user namespaces.

Heh, my first reaction was that you're over-reacting, but you're probably
right.  I don't want to conflict with the 'user_ns_map_uids' function,
so how about userns_fixup_signal_uids()?  Pls let me know if you have a
better name, otherwise I'll switch to this one.

thanks,
-serge
