From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: RE: [RFC][patch 8/11][CFQ-cgroup] Control cfq_data per cgroup
Date: Fri, 4 Apr 2008 15:20:39 +0900
Message-ID: <003401c8961c$00eea670$02cbf350$@jp.nec.com>
References: <007801c893d9$d89726f0$89c574d0$@jp.nec.com>	
	<008501c893dc$3206e520$9614af60$@jp.nec.com>
	<6599ad830804030835s73392db0v29426425c0ea4381@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830804030835s73392db0v29426425c0ea4381-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Paul Menage' <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org
List-Id: containers.vger.kernel.org

\> 
> On Tue, Apr 1, 2008 at 2:38 AM, Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
> wrote:
> >  +
> >  +static void *cfq_cgroup_init_cfq_data(struct cfq_cgroup *cfqc, struct
> cfq_data *cfqd)
> >  +{
> >  +       struct cgroup *child;
> >  +
> >  +       /* setting cfq_data for cfq_cgroup */
> >  +       if (!cfqc) {
> >  +               cfqc =
> cgroup_to_cfq_cgroup(get_root_subsys(&cfq_cgroup_subsys));
> 
> Rather than adding get_root_subsys(), can't you just keep a reference
> locally to your root subsystem state?
> 


If the cfqc has not specific address, namely cfqc is null, 
the cfq_cgroup_init_cfq_data function is called when new device is plugged.
In this time, it needs to relate new cfq_data data with top cfq_cgroup data.
Probably, a running program will be "insmod" in its time.
However, its program is not in root group.

On the supposition that only current interface is usedm,
If using current process, the top cgroup can be calculated by

   task_cgroup(current, cfq_subsys_id)->top_cgroup .

Therefore cfq_cgroup data of top cgroup is calculated by

   cgroup_to_cfq_cgroup(task_cgroup(current, cfq_subsys_id)->top_cgroup) .


However,  It would be bad to use "current" variable in order to
calculate cfq_cgroup data of top cgroup.
Because relationship between "calculating cfq_cgroup data of top cgroup" and
"running(current) task" is weak.


So that you say, root subsystem state maybe keep a reference locally.
For example, create a variable for root subsystem state and
store the pointer when making subsystem state first.

However, I think that it is smart to calculate root group of subsystems
when needing its information.
Does the current code have any problem?


Satoshi UCHIDA.
