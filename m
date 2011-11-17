From: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: fix freezing groups with stopped tasks
Date: Thu, 17 Nov 2011 18:03:46 +0100
Message-ID: <4EC53E72.5040408__27798.94388882$1321549443$gmane$org@inria.fr>
References: <1321480234-29241-1-git-send-email-mhocko@suse.cz>
	<4EC4DE9D.3040703@inria.fr>
	<20111117161318.GA1233@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111117161318.GA1233-VqjxzfR4DlwKmadIfiO5sKVXKuFTiq87@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Le 17/11/2011 17:13, Michal Hocko a =E9crit :
> On Thu 17-11-11 11:14:53, Tomasz Buchert wrote:
>> Hi,
>> I'm trying to understand now why I did that change in
>>
>> 2d3cbf8bc (the bug itself was in the if-the-else clause in
>> update_if_frozen , anyway).
>> Well, when I look at this now I think that there is nothing wrong
>> with your patch.
>> You can try my testcases from 2d3cbf8bc and 0bdba580, but it should be o=
k.
> Yes, I have tried it before sending the patch.
>
>> One thing I am not sure completely of is the following situation. So
>> the group is frozen
>> with the STOPPED task inside. There are few questions:
>> * if you send SIGCONT to the task now, will it wake up?
> No, it will enter refrigerator and wake up on thawing the group. Check
> out `goto relock' after do_signal_stop returns.
>
I've checked your patch empirically few hours before :).
Also I've read get_signal_to_deliver() and you are right - it's gonna be =

fine.
The decision is not mine, of course, but I suggest to merge it.
Good work!

Tomek
