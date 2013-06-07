From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file
	as insane
Date: Fri, 7 Jun 2013 14:32:34 +0400
Message-ID: <51B1B6C2.7000304__7518.65948918766$1370601119$gmane$org@parallels.com>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604201947.GE14916@htj.dyndns.org>
	<20130606092055.GF30217@redhat.com>
	<20130606211410.GF5045@htj.dyndns.org>
	<20130607101220.GE10742@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130607101220.GE10742-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/07/2013 02:12 PM, Daniel P. Berrange wrote:
>> The problem is that it doesn't make any sense to split threads of the
>> same process for at least two major controllers and you end up with
>> situation where you can't identify a resource to be belonging to a
>> certain cgroup because such level of granularity is simply undefined.
>> As I wrote before, we can special case certain controllers but I'm
>> extremely reluctant.  If you need it, please convince me.

It seems quite valid for me to split priority threads in a process and
give them a 80 % timeslice guarantee, while leaving only 20 % for
low-prio threads (for instance).

In general, I don't think that it would hurt to allow separation at
thread level *for the leaves*, specifically at the cpu related controllers.
