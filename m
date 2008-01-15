From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/4] The control group itself
Date: Tue, 15 Jan 2008 10:53:13 +0300
Message-ID: <478C6669.7070705@openvz.org>
References: <47833C3A.8090106@openvz.org> <47833FF6.6060901@openvz.org>
	<20080114174056.GB15077@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080114174056.GB15077-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

[snip]

> Thanks for working on this, Pavel.
> 
> My only question with this patch is - so if I create a devs
> cgroup which only has access to, say /dev/loop0 and /dev/tty3,
> and someone in that cgroup manages to create a new cgroup, the
> new cgroup will have all the default permissions again, rather
> than inherit the permissions from this cgroup, right?

Right. When you create a new cgroup you have an empty perms
set. Maybe it's worth inheriting the perms from the parent
container, but I think that empty set is better as you will
reconfigure it anyway.

[snip]

>> +static ssize_t devs_write(struct cgroup *cont, struct cftype *cft,
>> +		struct file *f, const char __user *ubuf,
>> +		size_t nbytes, loff_t *pos)
>> +{
>> +	int err, all, chrdev;
>> +	dev_t dev;
>> +	char buf[64];
>> +	struct devs_cgroup *devs;
>> +	mode_t mode;
> 
> (Of course this will require some privilege, i assume that's a detail
> you'll add next time around)

Hm... I though that privileges are governed at the cgroup level.... No?

[snip]
