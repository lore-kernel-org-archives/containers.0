From: "Chris R. Jones" <chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org>
Subject: lxc configuration help - only network isolated?
Date: Thu, 26 Mar 2009 15:45:41 -0700
Message-ID: <20090326224541.GA25769@versecorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

I have a couple of basic configuration questions on linux containers.  I'm using lxc-0.6.1.

I'm trying to configure a setup where I have two containers, where the only virtualized/isolated resources are network resources, but I can still do IPC between processes in the two containers.

The lxc.conf man page indicates that, "by default, the pids, sysv ipc, and mount points are virtualized and isolated. "

Is there a way in the configuration to specify that those resources should NOT be isolated?  I'd really like to have communication between two processes running in different containers using sysV IPC and signals.  The only thing I really want to be isolated are two different network namespaces.

Is there a setting I use in the lxc.conf file to accomplish this?

Up to now, I've been doing some prototyping using lxc-unshare -n, but that doesn't really create a container, correct?  That mostly accomplishes my goals, but I can't find a way to spawn new processes into that same namespace.  Is there a way, without defining a container?

Any recommendations on how to properly configure a containers to allow IPC between processes in two different containers while still isolating the network resources?

Thanks,
Chris
