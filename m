From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: nsgroup autoremoving
Date: Fri, 16 Jan 2009 10:52:17 -0600
Message-ID: <20090116165217.GA8477@us.ibm.com>
References: <49706006.80002@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49706006.80002-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Hi,
> 
> While trying to unshare a namespace with the clone syscall with an 
> inifinite loop, I got an EEXIST.
> That looks weird to have such syscall returning EEXIST ... :)
> 
> After investigating, it appears the ns_cgroup creates automatically a 
> control group named with the pid number when we call the clone syscall 
> with a namespace parameter and when the namespace exits, the control 
> group is not automatically removed. So when the pid numbers are recycled 
> we conflict with a previous ns_cgroup name and the clone fails.
> 
> IMHO, if the nsgroup is automatically created, it should automatically 
> destroyed, otherwise what will happen to application using the 
> namespaces (eg. mount namespace) wrote before nsgroup appeared ?

but you can have it automatically destroyed.  I.e. I did the
following:

mount -t cgroup -o freezer,ns freezer /cgroup
cat > /bin/release_cgroup.sh << EOF
#!/bin/sh
echo "Removing dead cgroup .$*." >> /var/log/cgroup
rmdir /cgroup/$* >> /var/log/cgroup 2>&1
echo "return value was $?" >> /var/log/cgroup
EOF
echo /bin/release_cgroup.sh > /cgroup/release_agent
echo 1 > /cgroup/notify_on_release
chmod ugo+x /bin/release_cgroup.sh
ns_exec -m /bin/sh
ls /cgroup`
	3581  notify_on_release  release_agent  tasks
exit
ls /cgroup
	notify_on_release  release_agent  tasks

-serge
