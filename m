From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH 3/3] CGroups: Add css_tryget()
Date: Thu, 11 Dec 2008 16:29:37 +0900
Message-ID: <20081211162937.2829e625.kamezawa.hiroyu__26299.5133096867$1228980833$gmane$org@jp.fujitsu.com>
References: <20081210233654.563182000@menage.corp.google.com>
	<20081210234432.407064000@menage.corp.google.com>
	<20081211141507.a087f270.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830812102328x52657bffm9864a0f9a4b3d5bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830812102328x52657bffm9864a0f9a4b3d5bd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 10 Dec 2008 23:28:12 -0800
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Wed, Dec 10, 2008 at 9:15 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> >
> > Could you add this ?
> > ==
> > bool    css_is_removed(struct cgroup_subsys_state *css)
> > {
> >        return test_bit(CSS_REMOVED, &css->flags);
> > }
> > ==
> > Then, I'll use this instead of memcg->obsolete flag.
> 
> I actually had a patch almost ready to send out the nuked memcg->obsolete.
> 
> A difference in mine is that I did
> 
> #define css_is_removed(__css) test_bit(CSS_REMOVED, &(__css)->css.flags)
> 
> so that you can use it on any subsystem state object that contains a
> "struct cgroup_subsys_state css;" field, which is currently all of
> them I think, without having to add the "->css" every time.
> 
ok, thx. very useful :)

-Kame
