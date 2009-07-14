From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Tue, 14 Jul 2009 14:26:16 -0700
Message-ID: <2f86c2480907141426r16f8ccf3o9770e25cc8d2e509__24289.9822457277$1247606905$gmane$org@mail.gmail.com>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
	<20090710230154.16778.58053.stgit@hastromil.mtv.corp.google.com>
	<1247596470.13426.16088.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247596470.13426.16088.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 14, 2009 at 11:34 AM, Dave Hansen<dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrot=
e:
> On Fri, 2009-07-10 at 16:01 -0700, Ben Blum wrote:
>> +struct cgroup_pidlist {
>> + =A0 =A0 =A0 /* protects the other fields */
>> + =A0 =A0 =A0 struct rw_semaphore mutex;
>> + =A0 =A0 =A0 /* array of xids */
>> + =A0 =A0 =A0 pid_t *list;
>> + =A0 =A0 =A0 /* how many elements the above list has */
>> + =A0 =A0 =A0 int length;
>> + =A0 =A0 =A0 /* how many files are using the current array */
>> + =A0 =A0 =A0 int use_count;
>> +};
>
> I think a slightly nicer way of doing this would be to use a structure
> like this:
>
> #define NR_PIDS (PAGE_SIZE-sizeof(struct list_head))
> struct pid_list {
> =A0 =A0 =A0 =A0struct list_head list;
> =A0 =A0 =A0 =A0pid_t pids[NR_PIDS];
> };
>
> That way, you can always kmalloc(sizeof(pid_list)), it fits nicely in
> PAGE_SIZE, and you can chain them together.
>
> Or, you could always just use one of the other flexible structures in
> the kernel like a radix_tree.
>
> -- Dave

This method looks to be a compromise between Andrew's proposed
generalized solution ( http://lkml.org/lkml/2009/7/2/518 ) and the
current quick-fix. The problem with it is that it'll require a layer
between whoever's using the array and managing the list structs (for
the case where we need to chain multiple blocks together), and if
we're going to put forth enough effort for that, we may as well go
ahead and write up a generalized kernel-wide library to fix this size
problem globally.
