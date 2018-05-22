From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Tue, 22 May 2018 09:43:46 -0400
Message-ID: <20180522134346.b3bm7ndfjjchju3b__28434.7005690963$1526996573$gmane$org@madcap2.tricolour.ca>
References: <1520257393.10396.291.camel@linux.vnet.ibm.com>
	<2397631.78oLu0QVqb@x2>
	<21646a72-e782-e33a-9e75-5cc98b241f36@linux.vnet.ibm.com>
	<4015765.rtofcNpGHU@x2>
	<e140278a-1494-ec74-f8bb-7fbac676306e@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e140278a-1494-ec74-f8bb-7fbac676306e-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-integrity <linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2018-05-21 17:57, Stefan Berger wrote:
> On 05/21/2018 02:30 PM, Steve Grubb wrote:
> > Hello Stefan,
> > =

> > On Monday, May 21, 2018 1:53:04 PM EDT Stefan Berger wrote:
> > > On 05/21/2018 12:58 PM, Steve Grubb wrote:
> > > > On Thursday, May 17, 2018 10:18:13 AM EDT Stefan Berger wrote:
> > > > > > audit_log_container_info() then releasing the local context.  T=
his
> > > > > > version of the record has additional concerns covered here:
> > > > > > https://github.com/linux-audit/audit-kernel/issues/52
> > > > > Following the discussion there and the concern with breaking user=
 space,
> > > > > how can we split up the AUDIT_INTEGRITY_RULE that is used in
> > > > > ima_audit_measurement() and ima_parse_rule(), without 'breaking u=
ser
> > > > > space'?
> > > > > =

> > > > > A message produced by ima_parse_rule() looks like this here:
> > > > > =

> > > > > type=3DINTEGRITY_RULE msg=3Daudit(1526566213.870:305): action=3D"=
dont_measure"
> > > > > fsmagic=3D"0x9fa0" res=3D1
> > > > Why is action and fsmagic being logged as untrusted strings? Untrus=
ted
> > > > strings are used when an unprivileged user can affect the contents =
of the
> > > > field such as creating a file with space or special characters in t=
he
> > > > name.
> > > > =

> > > > Also, subject and object information is missing. Who loaded this ru=
le?
> > > > =

> > > > > in contrast to that an INTEGRITY_PCR record type:
> > > > > =

> > > > > type=3DINTEGRITY_PCR msg=3Daudit(1526566235.193:334): pid=3D1615 =
uid=3D0 auid=3D0
> > > > > ses=3D2 subj=3Dunconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1=
023
> > > > > op=3D"invalid_pcr" cause=3D"open_writers" comm=3D"scp"
> > > > > name=3D"/var/log/audit/audit.log" dev=3D"dm-0" ino=3D1962625 res=
=3D1
> > > > Why is op & cause being logged as an untrusted string? This also has
> > > > incomplete subject information.
> > > It's calling audit_log_string() in both cases:
> > > =

> > > https://elixir.bootlin.com/linux/latest/source/security/integrity/int=
egrity
> > > _audit.c#L48
> > I see. Looking things over, I see that it seems like it should do the r=
ight
> > thing. But the original purpose for this function is here:
> > =

> > https://elixir.bootlin.com/linux/latest/source/kernel/audit.c#L1944
> > =

> > This is where it is logging an untrusted string and has to decide to en=
code
> > it or just place it in quotes. If it has quotes, that means it's an unt=
rusted
> > string but has no control characters in it. I think you want to use
> > audit_log_format() for any string that is trustworthy.
> =

> Replacing all occurrences (in IMA) of audit_log_string() with
> audit_log_format().
> > =

> > =

> > As an aside, I wonder why audit_log_string() is in the API when it is a
> > helper to audit_log_untrustedstring() ?  Without understanding the rule=
s of
> > untrusted strings, it can't be used correctly without re-inventing
> > audit_log_untrustedstring() by hand.
> > =

> > =

> > > > > Should some of the fields from INTEGRITY_PCR also appear in
> > > > > INTEGRITY_RULE? If so, which ones?
> > > > pid, uid, auid, tty, session, subj, comm, exe, res.  <- these are
> > > > required to be searchable
> > > > =

> > > > > We could probably refactor the current  integrity_audit_message()=
 and
> > > > > have ima_parse_rule() call into it to get those fields as well. I
> > > > > suppose adding new fields to it wouldn't be considered breaking u=
ser
> > > > > space?
> > > > The audit user space utilities pretty much expects those fields in =
that
> > > > order for any IMA originating events. You can add things like op or
> > > > cause before
> > > We will call into audit_log_task, which will put the parameters into
> > > correct order:
> > > =

> > > auid uid gid ses subj pid comm exe
> > I'm telling you what the correct order is.  :-)  A long time ago, the I=
MA
> =

> :-) Thanks. Was getting confused.
> =

> > system had audit events with the order I'm mentioning. For example, her=
e's
> > one from a log I collected back in 2013:
> > =

> > type=3DINTEGRITY_PCR msg=3Daudit(1327409021.813:21): pid=3D1 uid=3D0 au=
id=3D4294967295
> > ses=3D4294967295 subj=3Dkernel op=3D"add_template_measure" cause=3D"has=
h_added"
> > comm=3D"init" name=3D"01parse-kernel.sh" dev=3Drootfs ino=3D5413 res=3D0
> > =

> > it was missing "tty" and "exe", but the order is as I mentioned. The
> > expectation is that INTEGRITY events maintain this established order ac=
ross
> > all events.
> =

> I am *appending* exe=3D and tty=3D now:
> =

> type=3DINTEGRITY_PCR msg=3Daudit(1526939047.809:305): pid=3D1609 uid=3D0 =
auid=3D0
> ses=3D2 subj=3Dunconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> op=3D"invalid_pcr" cause=3D"open_writers" comm=3D"ssh"
> name=3D"/var/lib/sss/mc/passwd" dev=3D"dm-0" ino=3D1962679 res=3D1
> exe=3D"/usr/bin/ssh" tty=3Dtty2

This isn't necessary since they already covered in the already
connected SYSCALL record which duplicates even more information than is
already.

> =A0=A0 Stefan
> =

> > -Steve
> > =

> > > https://elixir.bootlin.com/linux/latest/source/kernel/auditsc.c#L2433
> > > =

> > > > that. The reason why you can do that is those additional fields are=
 not
> > > > required to be searchable by common criteria.
> > > > =

> > > > -Steve

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
