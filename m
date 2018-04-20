From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: [RFC PATCH ghak32 V2 05/13] audit: add containerid support for
	ptrace and signals
Date: Fri, 20 Apr 2018 12:13:37 -0400
Message-ID: <CAHC9VhREkg3uEkhMdKTM0S9-jXTR4LF_T5R2rgdNyfCo_4Meow__43920.5250390389$1524240701$gmane$org@mail.gmail.com>
References: <cover.1521179281.git.rgb@redhat.com>
	<8c7ff567377f4a83edac48e962c1b5b824b523c8.1521179281.git.rgb@redhat.com>
	<CAHC9VhTy4fX1hYfD5tppbP-fRaVRMXOfeJ=Et96J_rc7Jw12Bw@mail.gmail.com>
	<20180420010320.panie6mtdafxl65y@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180420010320.panie6mtdafxl65y-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Apr 19, 2018 at 9:03 PM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 2018-04-18 20:32, Paul Moore wrote:
>> On Fri, Mar 16, 2018 at 5:00 AM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

...

>> >  /*
>> >   * audit_log_container_info - report container info
>> > - * @tsk: task to be recorded
>> >   * @context: task or local context for record
>> > + * @op: containerid string description
>> > + * @containerid: container ID to report
>> >   */
>> > -int audit_log_container_info(struct task_struct *tsk, struct audit_context *context)
>> > +int audit_log_container_info(struct audit_context *context,
>> > +                             char *op, u64 containerid)
>> >  {
>> >         struct audit_buffer *ab;
>> >
>> > -       if (!audit_containerid_set(tsk))
>> > +       if (!cid_valid(containerid))
>> >                 return 0;
>> >         /* Generate AUDIT_CONTAINER_INFO with container ID */
>> >         ab = audit_log_start(context, GFP_KERNEL, AUDIT_CONTAINER_INFO);
>> >         if (!ab)
>> >                 return -ENOMEM;
>> > -       audit_log_format(ab, "contid=%llu", audit_get_containerid(tsk));
>> > +       audit_log_format(ab, "op=%s contid=%llu", op, containerid);
>> >         audit_log_end(ab);
>> >         return 0;
>> >  }
>>
>> Let's get these changes into the first patch where
>> audit_log_container_info() is defined.  Why?  This inserts a new field
>> into the record which is a no-no.  Yes, it is one single patchset, but
>> they are still separate patches and who knows which patches a given
>> distribution and/or tree may decide to backport.
>
> Fair enough.  That first thought went through my mind...  Would it be
> sufficient to move that field addition to the first patch and leave the
> rest here to support trace and signals?

I should have been more clear ... yes, that's what I was thinking; the
record format is the important part as it's user visible.

-- 
paul moore
www.paul-moore.com
