From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH, v3 2/2] cgroups: introduce timer slack subsystem
Date: Fri, 4 Feb 2011 15:34:39 +0200
Message-ID: <20110204133439.GA7181__23993.9254396178$1296826611$gmane$org@shutemov.name>
References: <1296679656-31163-1-git-send-email-kirill@shutemov.name>
	<1296679656-31163-3-git-send-email-kirill@shutemov.name>
	<20110202145605.6c9006fa@putvin>
	<20110203092229.GB1083@shutemov.name>
	<20110203095117.76a568fc@putvin>
	<AANLkTikvkUT8+U=bX6X2n7kMbnAt6evxTy1BqiX+TWpH@mail.gmail.com>
	<20110203115743.1ef9a4c2@putvin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110203115743.1ef9a4c2@putvin>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Feb 03, 2011 at 11:57:43AM -0800, Jacob Pan wrote:
> On Thu, 3 Feb 2011 10:12:51 -0800
> Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > On Thu, Feb 3, 2011 at 9:51 AM, Jacob Pan
> > <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> > >
> > > I think this logic defeats the purpose of having timer_slack
> > > subsystem in the first place. IMHO, the original intention was to
> > > have grouping effect of tasks in the cgroup.
> > 
> > You can get the semantics you want by just setting min_slack_ns =
> > max_slack_ns.
> > 
> true. it will just make set fail when min = max. it is awkward and
> counter intuitive when you want to change the group timer_slack. you
> will have to move both min and max to clamp the value, where set
> function can not be used.

Interface is very similar to /sys/devices/system/cpu/cpuX/cpufreq.
I think it's sane. If you want some extention, you can do it with
userspace helper.

> In addition, when a parent changes min = max, I don't see the current
> code enforce new settings on the children. Am i missing something?

I've missed it. I'll fix.

> In my use case, i want to put some apps into a managed group where
> relaxed slack value is used, but when time comes to move the app out of
> that cgroup, we would like to resore the original timer slack. I see
> having a current value per cgroup can be useful if we let timer code
> pick whether to use task slack value or the cgroup slack value.
> Or we have to cache the old value per task

What's mean "original timer slack" if you are free to move a task
between a lot of cgroups and process itself free to change it anytime?

-- 
 Kirill A. Shutemov
