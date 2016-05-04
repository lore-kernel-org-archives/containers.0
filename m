From: Phil Estes <estesp-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Wed, 04 May 2016 11:21:45 -0400
Message-ID: <572A1389.1040508__40621.5101866566$1462375327$gmane$org@gmail.com>
References: <1461880928.2307.48.camel@HansenPartnership.com>
	<20160428230045.GS22888@odin.tremily.us>
	<1461944328.2311.10.camel@HansenPartnership.com>
	<87wpn9988a.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87wpn9988a.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> James Bottomley<James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>  writes:
>
>> On Thu, 2016-04-28 at 16:00 -0700, W. Trevor King wrote:
>>> On Thu, Apr 28, 2016 at 03:02:08PM -0700, James Bottomley wrote:
>>>> /etc/usernamespaces
>>>>
>>>> and the format be :::
>>>>
>>>> =85
>>>>
>>>> If this sounds OK to people, I can code up a utility that does this,
>>>> which should probably belong in util-linux.
>>> This sounds a lot like shadow's newuidmap and newgidmap [1,2,3].
>>>
>>> Cheers,
>>> Trevor
>>>
>>> [1]: https://github.com/shadow-maint/shadow/commit/673c2a6f9aa6c69588f4=
c1be08589b8d3475a520
>>> [2]: http://man7.org/linux/man-pages/man1/newuidmap.1.html
>>> [3]: http://man7.org/linux/man-pages/man5/subuid.5.html
>> I think that mostly works.  No-one's packaging it yet, which is why I
>> didn't notice.  It also looks like the build dependencies have vastly
>> expanded, so I can't get it to build in the build service yet.
>
> Both Fedora and Ubuntu should be packaging it.  Further Docker should
> already be using these files.
Yes, based on our discussion in the PRs when user namespaces =

capabilities were added to Docker, we respect the /etc/sub{u,g}id files =

for sourcing mappings for userns-confined processes.

- Phil
