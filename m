From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [PATCH 1/2v6] procfs: show hierarchy of pid namespace
Date: Wed, 05 Nov 2014 13:51:31 +0100
Message-ID: <545A1D53.3070507@nod.at>
References: <1415184115-12022-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<1415184115-12022-2-git-send-email-chenhanxiao@cn.fujitsu.com>
	<545A13DA.3090207@nod.at> <20141105124111.GA19563@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20141105124111.GA19563-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Am 05.11.2014 um 13:41 schrieb Serge E. Hallyn:
> Quoting Richard Weinberger (richard-/L3Ra7n9ekc@public.gmane.org):
>> Am 05.11.2014 um 11:41 schrieb Chen Hanxiao:
>>> We lack of pid hierarchy information, and this will lead to:
>>> a) we don't know pids' relationship, who is whose child:
>>>    /proc/PID/ns/pid only tell us whether two pids live in different ns
>>> b) bring trouble to nested lxc container check/restore/migration
>>> c) bring trouble to pid translation between containers;
>>>
>>> This patch will show the hierarchy of pid namespace
>>> by pidns_hierarchy like:
>>>
>>> [root@localhost ~]#cat /proc/pidns_hierarchy
>>> 18060 18102 1534
>>> 18060 18102 1600
>>> 1550
>>
>> Hmm, what about printing the pid hierarchy in the same way as /proc/self/mountinfo
>> does with mount namespaces?
>> Your current approach is not bad but we should really try to be consistent with existing
>> sources of information.
> 
> Good point.  How would you structure it to make it look mor elike mountinfo?
> Adding the pidns inode number (in place of a mount sequence number) might be
> useful, but it sounds like you have a more concrete idea?

Just list <init_PID> <parent_of_init_PID>. This way we have exactly one
information record per line and always exactly two columns to parse.

e.g.
[root@localhost ~]#cat /proc/pidns_hierarchy
1550 1
18060 1
18102 18060
1534 18102
1600 18102

>> This function allocates memory per PID. If we have lots of PIDs, how does this scale?
>> I'd go so far and say this can be a DoS'able issue if the pidns_hierarchy file is opened multiple times...
> 
> It's not per pid, but per init-pid.  For non-reaper pids he bails and continue
> through the loop a few lines above.  This still may be DOS-able if users don't
> have kmem restrictions to prevent a ton of pid namespaces, but then the
> namespaces themselves will take a lot more memory than the representation here.

Ah, I've overlooked that fact. If it is per init-pid it is not that bad. :-)

Thanks,
//richard
