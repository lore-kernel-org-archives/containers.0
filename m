From: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 2/6] audit: log namespace serial numbers
Date: Sat, 10 May 2014 11:56:02 -0400
Message-ID: <1399737362.3558.22.camel@localhost>
References: <cover.1399681022.git.rgb@redhat.com>
	<e1b3ea66770e9e8d067c4fb725a6940c41ccf2f2.1399681022.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e1b3ea66770e9e8d067c4fb725a6940c41ccf2f2.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2014-05-09 at 20:27 -0400, Richard Guy Briggs wrote:

Not so relevant because you delete all of this code later...  But
still...

> +#ifdef CONFIG_NAMESPACES
> +void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk)
> +{
> +	struct nsproxy *nsproxy;
> +
> +	rcu_read_lock();

ok, so we are under rcu_read_lock() and cannot sleep

> +	nsproxy = task_nsproxy(tsk);
> +	if (nsproxy != NULL) {
> +		audit_log_format(ab, " mntns=%llx", nsproxy->mnt_ns->serial_num);

But this could do an allocation, are we sure that everything used
GFP_ATOMIC when creating the audit buffer? [hint: it doesn't]
