From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Tue, 22 May 2018 10:09:29 -0400
Message-ID: <1705289.eIvaqvarKh__16372.8162333884$1526998069$gmane$org@x2>
References: <1520257393.10396.291.camel@linux.vnet.ibm.com>
	<4015765.rtofcNpGHU@x2>
	<e140278a-1494-ec74-f8bb-7fbac676306e@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-integrity <linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Monday, May 21, 2018 5:57:29 PM EDT Stefan Berger wrote:
> >>>> Should some of the fields from INTEGRITY_PCR also appear in
> >>>> INTEGRITY_RULE? If so, which ones?
> >>> 
> >>> pid, uid, auid, tty, session, subj, comm, exe, res.  <- these are
> >>> required to be searchable
> >>> 
> >>>> We could probably refactor the current  integrity_audit_message() and
> >>>> have ima_parse_rule() call into it to get those fields as well. I
> >>>> suppose adding new fields to it wouldn't be considered breaking user
> >>>> space?
> >>> 
> >>> The audit user space utilities pretty much expects those fields in that
> >>> order for any IMA originating events. You can add things like op or
> >>> cause before
> >> 
> >> We will call into audit_log_task, which will put the parameters into
> >> correct order:
> >> 
> >> auid uid gid ses subj pid comm exe
> > 
> > I'm telling you what the correct order is.  :-)  A long time ago, the IMA
> 
>  Thanks. Was getting confused.
> 
> > system had audit events with the order I'm mentioning. For example,
> > here's one from a log I collected back in 2013:
> > 
> > type=INTEGRITY_PCR msg=audit(1327409021.813:21): pid=1 uid=0
> > auid=4294967295 ses=4294967295 subj=kernel op="add_template_measure"
> > cause="hash_added" comm="init" name="01parse-kernel.sh" dev=rootfs
> > ino=5413 res=0
> > 
> > it was missing "tty" and "exe", but the order is as I mentioned. The
> > expectation is that INTEGRITY events maintain this established order
> > across all events.
> 
> I am *appending* exe= and tty= now:
> 
> type=INTEGRITY_PCR msg=audit(1526939047.809:305): pid=1609 uid=0 auid=0
> ses=2 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> op="invalid_pcr" cause="open_writers" comm="ssh"
> name="/var/lib/sss/mc/passwd" dev="dm-0" ino=1962679 res=1
> exe="/usr/bin/ssh" tty=tty2

It is safe to put them where they belong. The tools currently skip over tty 
and exe if they would be present. So, nothing would get messed up. Its very 
simple to add an "if" statement to check for these new fields and collect 
them for searching. Also, "res" is traditionally the last field in any event.

Thanks,
-Steve
