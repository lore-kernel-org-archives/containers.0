From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: nets: status of sysfs with netns
Date: Fri, 11 Apr 2008 17:33:03 +0200
Message-ID: <47FF84AF.5040302@fr.ibm.com>
References: <47DA9BEA.9070907@bull.net> <47DA9D71.2010707@openvz.org>
	<m1lk4gufto.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1lk4gufto.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> =

>> Benjamin Thery wrote:
>>> Eric, Pavel,
>>>
>>> I haven't followed everything about the sysfs/netns issue recently and =
I =

>>> think I have missed some of its recent developments in the past weeks. =

>>> So I'm wondering what is the current status? Is anyone still working on=
 it?
>> I'm thinking on it, but have no graceful solution :( Sysfs is a big...
>> no - HUUUUUUUUUUGE problem.
>>
>>> As several netns patches for IPv4 and IPv6 have already been merged in =

>>> net-2.6.26, it would be great to have the sysfs part also to help peopl=
e =

>>> who want test netns.
>>> Right now, it is a pain to boot and test a system with CONFIG_SYSFS=3Dn.
>>>
>>> (I know the problem is not trivial and won't be easy to solve. I just =

>>> want to be sure it is not forgotten)
>> It is (unfortunately) not.
>>
>>> Pavel, I've heard you sent (or have) a patch that prevents sysfs access =

>>> from a "child" netns. A patch that can be a good workaround until we =

>>> have the full thing ready. I can't find it in mailing lists archives, =

>>> can you give some hints about where to find it? :)
>> Hm. I haven't had plans to do such things actually.
>>
>>> Thanks a lot.
> =

> Sorry guys.  I think my initial reply got lost.
> =

> Currently my approach was approved in code review.  The only hold up
> seems to be time, and gregkh getting overloaded and dropping the
> patches, for the Nth time.

Hi Eric,

I tryed to look at your patchset but I was unable to find it. Do you =

have it somewhere available ? I was guessing I could play with it and by =

the way test it a little ;)

Thanks
  -- Daniel













































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92400
Courbevoie
RCS Nanterre 552 118 465
Forme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
