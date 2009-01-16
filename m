From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: nsgroup autoremoving
Date: Fri, 16 Jan 2009 11:23:02 +0100
Message-ID: <49706006.80002@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux- >> Meiosys Linux Development Interlock" <linux-meiosys-dev-cunTk1MwBs/+dQ4Jr4kqwkEOCMrvLtNR@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

While trying to unshare a namespace with the clone syscall with an 
inifinite loop, I got an EEXIST.
That looks weird to have such syscall returning EEXIST ... :)

After investigating, it appears the ns_cgroup creates automatically a 
control group named with the pid number when we call the clone syscall 
with a namespace parameter and when the namespace exits, the control 
group is not automatically removed. So when the pid numbers are recycled 
we conflict with a previous ns_cgroup name and the clone fails.

IMHO, if the nsgroup is automatically created, it should automatically 
destroyed, otherwise what will happen to application using the 
namespaces (eg. mount namespace) wrote before nsgroup appeared ?

Thanks.
  -- Daniel
