From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/3] Switch IPC namespace to use sysctl shadows
Date: Wed, 21 Nov 2007 12:21:06 +0300
Message-ID: <4743F882.7010607@openvz.org>
References: <4742C73C.3010904@openvz.org> <4742C95D.1040907@openvz.org>
	<1195579453.29578.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1195579453.29578.8.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Tue, 2007-11-20 at 14:47 +0300, Pavel Emelyanov wrote:
>>
>> +int ipc_clone_sysctl(struct ipc_namespace *ns)
>> +{
>> +       struct ctl_table_header *h;
>> +       struct ctl_table *t;
>> +
>> +       h = create_sysctl_shadow(init_ipc_ns.ctl_head);
>> +       if (h == NULL)
>> +               return -ENOMEM;
>> +
>> +       t = h->ctl_table->child;
>> +
>> +       t[0].data = &ns->shm_ctlmax;
>> +       t[1].data = &ns->shm_ctlall;
>> +       t[2].data = &ns->shm_ctlmni;
>> +       t[3].data = &ns->msg_ctlmax;
>> +       t[4].data = &ns->msg_ctlmni;
>> +       t[5].data = &ns->msg_ctlmnb;
>> +       t[6].data = &ns->sem_ctls;
>> +
>> +       ns->ctl_head = h;
>> +       return 0;
>> +} 
> 
>>From where does the order for these things come?

From the original tables.

> -- Dave
> 
> 
