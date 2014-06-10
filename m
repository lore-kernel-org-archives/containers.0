From: Marian Marinov <mm-NV7Lj0SOnH0@public.gmane.org>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
	kmem limit doesn't recover after disk i/o causes limit to be hit]
Date: Tue, 10 Jun 2014 17:50:11 +0300
Message-ID: <53971B23.8000509__15286.5846678198$1402412294$gmane$org@yuhu.biz>
References: <20140416154650.GA3034@alpha.arachsys.com>	<20140418155939.GE4523@dhcp22.suse.cz>	<5351679F.5040908@parallels.com>	<20140420142830.GC22077@alpha.arachsys.com>	<20140422143943.20609800@oracle.com>	<20140422200531.GA19334@alpha.arachsys.com>	<535758A0.5000500@yuhu.biz>
	<20140423084942.560ae837@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3064198606616017338=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140423084942.560ae837-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Richard Davies <richard-li8END47hbdWk0Htik3J/w@public.gmane.org>, Vladimir Davydov <vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, William Dauchy <wdauchy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============3064198606616017338==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="3GVEq5bqWT2KnhLROH8Ev1bRXASdGQ3PF"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3GVEq5bqWT2KnhLROH8Ev1bRXASdGQ3PF
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/23/2014 03:49 PM, Dwight Engen wrote:
> On Wed, 23 Apr 2014 09:07:28 +0300
> Marian Marinov <mm-NV7Lj0SOnH0@public.gmane.org> wrote:
>=20
>> On 04/22/2014 11:05 PM, Richard Davies wrote:
>>> Dwight Engen wrote:
>>>> Richard Davies wrote:
>>>>> Vladimir Davydov wrote:
>>>>>> In short, kmem limiting for memory cgroups is currently broken.
>>>>>> Do not use it. We are working on making it usable though.
>>> ...
>>>>> What is the best mechanism available today, until kmem limits
>>>>> mature?
>>>>>
>>>>> RLIMIT_NPROC exists but is per-user, not per-container.
>>>>>
>>>>> Perhaps there is an up-to-date task counter patchset or similar?
>>>>
>>>> I updated Frederic's task counter patches and included Max
>>>> Kellermann's fork limiter here:
>>>>
>>>> http://thread.gmane.org/gmane.linux.kernel.containers/27212
>>>>
>>>> I can send you a more recent patchset (against 3.13.10) if you
>>>> would find it useful.
>>>
>>> Yes please, I would be interested in that. Ideally even against
>>> 3.14.1 if you have that too.
>>
>> Dwight, do you have these patches in any public repo?
>>
>> I would like to test them also.
>=20
> Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:
>=20
> git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
> git://github.com/dwengen/linux.git cpuacct-task-limit-3.14

I did a backport of the patches to 3.12.16 and forward ported them to 3.1=
2.20.

I'm very happy with how they work.

I used the patches on machines with 10-20k processes and it worked perfec=
tly when some of the containers spawned 100s of
processes. It really saved us when one of the containers was attacked :)

The only thing that I'm going to add is on the fly change of the limit.

Marian

> =20
>> Marian
>>
>>>
>>> Thanks,
>>>
>>> Richard.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe cgroups"
>>> in the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20



--3GVEq5bqWT2KnhLROH8Ev1bRXASdGQ3PF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlOXGyMACgkQ4mt9JeIbjJSbZwCfYE/EfljGWfMgz0MxBcNArv+1
uIIAnjDyTp++AzAotNpxNRj5ZyBtdi85
=ruWh
-----END PGP SIGNATURE-----

--3GVEq5bqWT2KnhLROH8Ev1bRXASdGQ3PF--


--===============3064198606616017338==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============3064198606616017338==--
