From: Renato Westphal <renatowestphal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: LXC L3 network isolation, yes/no ?, how ?
Date: Wed, 2 Nov 2011 18:11:44 -0200
Message-ID: <CAChaegkNVXQmro21u2bBsH2pDje7a+fooV9eRg0aUsmTdjvXOQ@mail.gmail.com>
References: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
	<m1r51swmun.fsf@fess.ebiederm.org>
	<20111101043201.GA14734@faui40p.informatik.uni-erlangen.de>
	<m1lis0vxu6.fsf@fess.ebiederm.org>
	<20111101152624.GB14734@faui40p.informatik.uni-erlangen.de>
	<m1hb2nsqy6.fsf@fess.ebiederm.org>
	<20111102195142.GC14734@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111102195142.GC14734-+4JsuViRYHWM0MU9lROt9PpTrGXM5HoexJJUWDj/nkeELgA04lAiVw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Toerless Eckert <Toerless.Eckert-jNDFPZUTrfT6U6xlzOR6HsSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

2011/11/2 Toerless Eckert <Toerless.Eckert-jNDFPZUTrfT6U6xlzOR6HsSSVFg4/55HhC4ANOJQIlc@public.gmane.org>:
> Cool. Although i would claim my bits are "current", and your bits
> are "bleeding edge". Just found the iproute2 package that supports this
> on my gentoo by getting the latest cvs version only... ;-)
>
> The biggest issue seems to be that setns() is only in 3.0 linux kernels
> as far as i can see. Have to check whether that's a possible version on t=
he
> systems where i need it.

Backporting the setns syscall and related stuff to older linux kernels
is straightforward. I backported it to the 2.6.35.13 release and
everything is working fine. if you are interested let me know.

> But at least this is technically cool and makes these network name spaces
> much more flexible useable (eg: inside and outside of LXC).
>
> Cheers
> =A0 =A0Toerless
>
> On Tue, Nov 01, 2011 at 10:17:05AM -0700, Eric W. Biederman wrote:
>> > some setns(XXXX) system call, it's really difficult to use these netwo=
rk name
>> > spaces outside of a concept like LXC - which is a shame, because other=
wise
>> > the nework name space woudl exactly be what i am looking for.
>>
>> Definitely old docs.
>>
>> ip netns add
>> ip netns delete
>> ip netns exec
>>
>> And yes there is a setns system call.
>>
>> If you don't have that you have old bits. =A0All of that should be merged
>> and documented.
>>
>> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>



-- =

Renato Westphal
