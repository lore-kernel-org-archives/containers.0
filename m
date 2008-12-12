From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: ns_can_attach (nsproxy cgroup)
Date: Fri, 12 Dec 2008 10:51:53 +0100
Message-ID: <20081212095153.GA20956@megiteam.pl>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

Is there a good reason for ns_can_attach to restrict moving tasks only
to direct descentants of the current cgroup? I.e. could the code:

        orig = task_cgroup(task, ns_subsys_id);
        if (orig && orig != new_cgroup->parent)
                return -EPERM;

be replaced with:

        orig = task_cgroup(task, ns_subsys_id);
        if (orig && !cgroup_is_descendant_of(new_cgroup, orig))
                return -EPERM;

(for a suitable definition of cgroup_is_descendant_of). It would allow
moving tasks down the cgroup hierarchy more than one level at a time and
as far as I can see, would pose no additional problems.

Please keep CC'd, I'm not subscribed.

Best regards,
 Grzegorz Nosek
