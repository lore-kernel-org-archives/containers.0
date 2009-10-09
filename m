From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] cr: add selinux support (v6)
Date: Fri, 9 Oct 2009 17:31:11 -0500
Message-ID: <20091009223111.GA7951@us.ibm.com>
References: <20091009205552.GA5778@us.ibm.com>
	<20091009205731.GC5823@us.ibm.com> <4ACFA7F1.6060209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ACFA7F1.6060209-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel J Walsh (dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On 10/09/2009 04:57 PM, Serge E. Hallyn wrote:
> I think you need to be careful with this.  We do not want the process to
> start with the same MCS Label as when it stopped in case some other virtual
> machine has grabbed the MCS Label.  When the image is taken down it should
> give up probably give up its labels and allow the system to relabel to a
> known state.  When it starts the image again, new labels should be selected
> and set on disk and the process resumed with the new label.

With this patchset, the default behavior remains to simply run the
restarted task in whatever context is calculated by the usual TE
rules (i.e. current context unless the type of the 'restart' program
was an entry type to some domain and a domain transition was requested
or automatic).  The request to restore checkpointed labels is done with
a special flag.

What you actually are suggesting is the ability to make fine-grained
changes to some of the checkpointed labels, but to still restore
the checkpointed labels (with changes).  I think it is pretty
generally accepted that such things should be done by editing the
checkpoint image in userspace.  A pretty simple program could
run through the image looking for CKPT_HDR_SEC fields and
change the MCS labels where appropriate.

I haven't written such a program (or used MCS), but if you like
I'll certainly write it and I suspect Oren would be happy to have
it in user-cr/ (where the checkpoint and restart programs live) as
an example of how to make such substitutions generally.

thanks,
-serge
