From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 8/9] [RFC] Example multi-bindable subsystem: a
	per-cgroup  notes field
Date: Thu, 2 Jul 2009 12:17:28 +0900
Message-ID: <20090702121728.2a7c93cd.kamezawa.hiroyu__3673.13614483482$1246504792$gmane$org@jp.fujitsu.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021133.14469.35140.stgit@menage.mtv.corp.google.com>
	<20090702114829.df04c885.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907011956i33769d5ek5401e93553d75c59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907011956i33769d5ek5401e93553d75c59-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 1 Jul 2009 19:56:28 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Wed, Jul 1, 2009 at 7:48 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> >
> > Hmm, do we need to this "info" file as subsys ? How about making this as
> > default file set ? (if there are users.)
> >
> 
> That would certainly be possible, and would be an alternative to
> having multi-bindable subsystem support.
> 
> The advantage of adding multi-bindable subsystems is that you can
> avoid bloating the core cgroups code, by putting individual small
> cgroups features in their own code modules, and you get to decide at
> mount time which features are actually mounted; if they were part of
> the core cgroups files, then there would either need to be special
> mount options for each separate feature, or else no way to pick which
> features were mounted on each hierarchy.
> 
Sure, thanks.

-Kame

> Paul
> 
