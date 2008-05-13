From: Balaji Rao <balajirrao@gmail.com>
Subject: Re: [RFC][-mm] Simple stats for cpu resource controller v4
Date: Tue, 13 May 2008 09:00:27 +0530
Message-ID: <200805130900.27492.balajirrao@gmail.com>
References: <200804052339.46632.balajirrao@gmail.com> <200805120148.37856.balajirrao@gmail.com> <20080512164833.8354abeb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759071AbYEMDba@vger.kernel.org>
In-Reply-To: <20080512164833.8354abeb.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, balbir@in.ibm.com, vatsa@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, dada1@cosmosbay.com
List-Id: containers.vger.kernel.org

On Tuesday 13 May 2008 05:18:33 am Andrew Morton wrote:
> On Mon, 12 May 2008 01:48:37 +0530
>
> Balaji Rao <balajirrao@gmail.com> wrote:
> > Hi Andrew,
> >
> > Here's a version that uses percpu_counters and which actually works=
=2E The
> > only evil it contains is the check,
> >
> > 	if (percpu_counter_ready) {
> > 		..
> > 	}
>
> There's no instance of "percpu_counter_ready" in the patch so I'm a b=
it
> stumped.
>
Here it is. 'stat' can tell us if percpu_counters are ready or not.

+static void __cpu_cgroup_stat_add(struct cpu_cgroup_stat *stat,
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0enum cpu_cgroup_stat_inde=
x idx, int val)
+{
+=A0=A0=A0=A0=A0=A0=A0if (stat)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0percpu_counter_add(&stat-=
>cpustat[idx], val);
+}
+#endif

It's here as well.

+static s64 cpu_cgroup_read_stat(struct cpu_cgroup_stat *stat,
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0enum cpu_cgroup_stat_inde=
x idx)
+{
+=A0=A0=A0=A0=A0=A0=A0if (stat)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return percpu_counter_rea=
d(&stat->cpustat[idx]);
+
+=A0=A0=A0=A0=A0=A0=A0return 0;
+}
+
> > @@ -3837,6 +3858,16 @@ void account_user_time(struct task_struct *p=
,
> > cputime_t cputime) cpustat->nice =3D cputime64_add(cpustat->nice, t=
mp);
> >  	else
> >  		cpustat->user =3D cputime64_add(cpustat->user, tmp);
> > +
> > +       /* Charge the task's group */
> > +#ifdef CONFIG_CGROUP_SCHED
> > +	{
> > +		struct task_group *tg;
> > +		tg =3D task_group(p);
> > +		__cpu_cgroup_stat_add(tg->stat, CPU_CGROUP_STAT_UTIME,
> > +				cputime_to_msecs(cputime));
> > +	}
> > +#endif
> >  }
> >
> >  /*
> > @@ -3892,8 +3923,17 @@ void account_system_time(struct task_struct =
*p,
> > int hardirq_offset, cpustat->irq =3D cputime64_add(cpustat->irq, tm=
p);
> >  	else if (softirq_count())
> >  		cpustat->softirq =3D cputime64_add(cpustat->softirq, tmp);
> > -	else if (p !=3D rq->idle)
> > +	else if (p !=3D rq->idle) {
> >  		cpustat->system =3D cputime64_add(cpustat->system, tmp);
> > +#ifdef CONFIG_CGROUP_SCHED
> > +		{
> > +			struct task_group *tg;
> > +			tg =3D task_group(p);
> > +			__cpu_cgroup_stat_add(tg->stat, CPU_CGROUP_STAT_STIME,
> > +					cputime_to_msecs(cputime));
> > +		}
> > +	}
> > +#endif
>
> I'd suggest that the above be turned into calls to a helper function
> which is a no-op if !CONFIG_CGROUP_SCHED.

OK. Will do.

--=20
Warm Regards,

Balaji Rao
Dept. of Mechanical Engineering
NITK
