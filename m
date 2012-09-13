From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 cgroup/for-3.7] cgroup: mark subsystems with broken
	hierarchy support and whine if cgroups are nested for them
Date: Thu, 13 Sep 2012 16:17:49 -0400
Message-ID: <20120913201748.GN4396@redhat.com>
References: <20120913183402.GG7677@google.com>
	<20120913192058.GH7677@google.com>
	<20120913194111.GM4396@redhat.com>
	<20120913200354.GN7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120913200354.GN7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 13, 2012 at 01:03:54PM -0700, Tejun Heo wrote:
> Hello, Vivek.
> 
> On Thu, Sep 13, 2012 at 03:41:11PM -0400, Vivek Goyal wrote:
> > I think for blkio controller, first level of creation itself is wrong if
> > hierarchy is not supported. 
> > 
> > 				root
> > 			       / | \ 
> >                               T1 T2 G1
> > 
> > So T1 and T2 are tasks and G1 is the created cgroup. Now if we are
> > expecting hierarchical controller then like cpu controller, T1, T2 and
> > G1 should be considered at same level and disk bandwidth should be
> > divided equally between T1, T2 and G1.
> > 
> > But currently blkio controller looks at them as follows.
> > 
> > 				pivot
> > 				/  \
> > 			      root G1
> > 			      / \
> > 			     T1  T2
> > and divides bandwidth between root and G1 equally (if weights are equal).
> 
> Yeah, how to handle tasks and groups under the same cgroup is a
> difficult question.  I don't think what blkcg does now is necessarily
> wrong and am not particularly fond of the idea of dealing tasks and
> groups as equals.  It isn't clear how resource should be distributed
> across them - we don't have per-task knobs.

IIUC cpu controller tied together the notion of task priority and
cgroup weight. We could do something similar where we map the task
io priority to some weight and then divide bandwidth according to
that. That give us some control on tasks.

In the past we had this discussion and consensus seemed to be go
the cpu controller way where task and groups are treated at same
level when it comes to bandwidth division. One can always move all
the tasks to one of the children groups if this behavior is not
desired. The only problem is that kernel does not seem to offer
any fool proof way of moving existing process to a cgroup (making
sure none of the threads escaped the movement). Possibly freezer
controller could help here but I am not sure how it would freeze
threads in root cgroup which might require to be moved out to a
children group.

> 
> I think this is a problem only for controllers which implement
> proportional control - cpu and blkio, am I right?

I think this might become a problem with throttling too if somebody was
throttling root group. Throttling root group is not recommended so that
might not be a big issue. (Though there is nothing in the code which
prevents it).

So you are right. Looks like cpu and block proportional control have this
issue. Memory controller might have handled it already using .use_hiearchy
i am assuming.

Thanks
Vivek
