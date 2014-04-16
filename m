From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.16] cgroup: add documentation about unified
	hierarchy
Date: Wed, 16 Apr 2014 09:51:20 -0400
Message-ID: <20140416135120.GI30990@htj.dyndns.org>
References: <20140414220917.GD1863@htj.dyndns.org>
	<534DB46D.7090207@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <534DB46D.7090207-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Brandon Philips <brandon.philips-JW9irJGTvgXQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Tue, Apr 15, 2014 at 03:36:29PM -0700, Randy Dunlap wrote:
> > +cgroup allows arbitrary number of hierarchies and each hierarchy can
> 
>           allows an arbitrary
> 
> > +host any number of controllers.  While this seems to provide high
> 
>                                                         provide a high

Updated.

> > +depending on the specific controller.  IOW, hierarchy may be collapsed
> 
> please spell out IOW

Updated, but is this really necessary?

> > +from leaf towards root when viewed from specific controllers.  For
> > +example, a given configuration might not care about how memory is
> > +distributed beyond certain level while still want to control how cpu
> 
>                beyond a certain level while still wanting to control

Updated.

> I would prefer to see CPU instead of cpu (except when it refers to a
> task or function).

cpu sometimes refer to the cpu controller.  Will use CPU when it's
actually referring to the CPU.

> > +mixing unified hierarchy with the traditional multiple hierarchies in
> > +fully backward compatible way.
> 
>    a fully backward

Updated.

> > +
> > +When read, the file contains space-separated list of currently enabled
> 
>                        contains a space-separated

Updated.

> > +controllers.  A write to the file should contain spaced-separated list
> 
>                                             contain a space-separated

Updated.

> > +2-3. cgroup.controllers
> > +
> > +Read-only "cgroup.controllers" contains space-separated list of
> 
>                                   contains a space-separated

Updated.

> > +It is clear that this is something which needs to be addressed from
> > +cgroup core proper in a uniform way so that controllers don't need to
> > +worry about it and cgroup as a whole shows a consistent and logical
> > +behavior.  To achieve that, unified hierarchy enforces the following
> > +structural constraint.
> 
>    structural constraint:

Updated.

> > +There are two things to note.  Firstly, the root cgroup is exempt from
> > +the restriction.  Root contains tasks and anonymous resource
> > +consumption which can't be associated with any other cgroup and
> > +requires special treatment from most controllers.  How resource
> > +consumption in the root cgroup is governed is upto each controller.
> 
>                                                  up to

Updated.

> > +- There is single monitoring point at the root.  There's no way to
> > +  delegate management of subtree.
> 
> "of subtree" seems incomplete...
> At a minimum it should be "of a subtree."

Changed to "of a subtree".

> > +
> > +- The event isn't recursive.  It triggers when a cgroup doesn't have
> > +  any tasks or child cgroups.  Events for internal nodes trigger only
> > +  after all children are removed.  This again makes it impossible to
> > +  delegate management of subtree.
> 
>                          of a subtree.

Ditto.

> > +
> > +- Events are filtered from the kernel side.  "notify_on_release" file
> 
>                                                 A "notify_on_release" file
> 
> > +  is used to subscribe to or suppress release event.  This is
> 
>                                          release events.

Updated.

> > +  unnecessarily complicated and probably done this way because event
> > +  delivery itself was expensive.
> > +
> > +Unified hierarchy implements interface file "cgroup.subtree_populated"
> 
>                      implements an interface file

Updated.

> > +In unified hierarchy, release_agent mechanism is no longer supported
> 
>                          the release_agent mechanism

Updated.

> > +This, in part, is to prevent cgroup interface from being inadvertently
> 
>                         prevent the cgroup interface

Updated.

> > +cgroup" in race-free way or make multiple operations atomic against
> 
>            in a race-free way

Updated.

> > +migration to another cgroup.
> > +
> > +Another aspect is that, for better or for worse, cgroup interface goes
> 
>                                                     the cgroup interface goes

Updated.

> > +through far less scrutiny than regular interfaces for unprivileged
> > +userland.  The upside is that cgroup is able to expose useful features
> > +which may not be suitable for general consumption in reasonable time
> 
>                                                      in a reasonable time

Updated.

> > +frame.  It provides a relatively short path between internal details
> > +and userland-visible interface.  Of course, this shortcut comes with
> > +high risk.  We go through what we go through for general kernel APIs
> > +for good reasons.  It may end up leaking internal details in a way
> > +which can exert significant pain by locking the kernel into a contract
> > +that can't be maintained in a reasonable manner.
> 
> so the cgroup interface is not stable and won't be?

It'll be as stable as any other administration interfaces - sysctl,
iptables and so on, which are stable but can usually be deprecated if
really necessary whereas a syscall interface exposed to lay programs
has to be maintained for actual eternity.  It comes from the fact that
the administrative tools are naturally more closely coupled with the
kernel and the time it takes to reach the point where nobody notices
removal of deprecated interface often measures in years rather than
eternity.

> > +Also, due to the specific nature, cgroup and its controllers don't
> > +tend to attract attention from wide-scope of developers.  cgroup's
> 
>                              from a wide scope of developers.

Updated.

> > +Keeping cgroup as an administration interface is both advantageous for
> > +its role and an imperative given its nature.  Some of the cgroup
> 
>             and imperative given

Updated.  Dang articles.

> Two comments that apply in multiple places:
> 
> a.  Call cgroup's interface files "files".  E.g.:
> 
>   root's "cgroup.subtree_control" determines ...
> 
> becomes:
> 
>   root's "cgroup.subtree_control" file determines
> 
> b.  Call cgroup controllers "controllers" or "controller".  E.g.:
> 
>   memory currently doesn't have a way to control what happens between
> 
> becomes:
> 
>   The memory controller currently doesn't have a way to control what happens between

Updated.

Thanks a lot for the review!

-- 
tejun
