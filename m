From: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Subject: Re: [RFC] Per-user namespace process accounting
Date: Thu, 29 May 2014 13:40:42 +0300
Message-ID: <53870EAA.4060101@1h.com>
References: <5386D58D.2080809@1h.com> <87tx88nbko.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tx88nbko.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
List-Id: containers.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 05/29/2014 01:06 PM, Eric W. Biederman wrote:
> Marian Marinov <mm-108MBtLGafw@public.gmane.org> writes:
> 
>> Hello,
>> 
>> I have the following proposition.
>> 
>> Number of currently running processes is accounted at the root user namespace. The problem I'm facing is that
>> multiple containers in different user namespaces share the process counters.
> 
> That is deliberate.

And I understand that very well ;)

> 
>> So if containerX runs 100 with UID 99, containerY should have NPROC limit of above 100 in order to execute any 
>> processes with ist own UID 99.
>> 
>> I know that some of you will tell me that I should not provision all of my containers with the same UID/GID maps,
>> but this brings another problem.
>> 
>> We are provisioning the containers from a template. The template has a lot of files 500k and more. And chowning
>> these causes a lot of I/O and also slows down provisioning considerably.
>> 
>> The other problem is that when we migrate one container from one host machine to another the IDs may be already
>> in use on the new machine and we need to chown all the files again.
> 
> You should have the same uid allocations for all machines in your fleet as much as possible.   That has been true
> ever since NFS was invented and is not new here.  You can avoid the cost of chowning if you untar your files inside
> of your user namespace.  You can have different maps per machine if you are crazy enough to do that.  You can even
> have shared uids that you use to share files between containers as long as none of those files is setuid.  And map
> those shared files to some kind of nobody user in your user namespace.

We are not using NFS. We are using a shared block storage that offers us snapshots. So provisioning new containers is
extremely cheep and fast. Comparing that with untar is comparing a race car with Smart. Yes it can be done and no, I
do not believe we should go backwards.

We do not share filesystems between containers, we offer them block devices.

> 
>> Finally if we use different UID/GID maps we can not do live migration to another node because the UIDs may be
>> already in use.
>> 
>> So I'm proposing one hack modifying unshare_userns() to allocate new user_struct for the cred that is created for
>> the first task creating the user_ns and free it in exit_creds().
> 
> I do not like the idea of having user_structs be per user namespace, and deliberately made the code not work that
> way.
> 
>> Can you please comment on that?
> 
> I have been pondering having some recursive resources limits that are per user namespace and if all you are worried
> about are process counts that might work.  I don't honestly know what makes sense at the moment.

It seams to me that the only limit(from RLIMIT) that are generally a problem for the namespaces is number of processes
and pending signals.
This is why I proposed the above modification. However I'm not sure if the places I have chosen are right and also I'm
not really convinced that having per-namespace user_struct is the right approach for the process counter.

> 
> Eric
> 
Marian

- -- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman-/eSpBmjxGS4dnm+yROfE0A@public.gmane.org
ICQ: 7556201
Mobile: +359 886 660 270
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlOHDqoACgkQ4mt9JeIbjJRLPACZARH6agr856HeoB3Ub+e6U1PI
ICgAoLbQTRM2SqcYOLep7WPIeuoiw4aB
=/Ii4
-----END PGP SIGNATURE-----
