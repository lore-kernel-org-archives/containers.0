From: Adam Gidux <adam.gidux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: netlimit, bandwidth accounting, and other resources
Date: Mon, 25 Jun 2012 09:30:03 -0500
Message-ID: <CANzjhQUc5L=+sGruSWH1vSr8w01X-brPjEvDNpBpnn9-3mh4sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

request for information on lxc containers

disro: archlinux
goal: lxc vps containers

network throttling (netlimit) (via cgroup) (building a kmod for use
with modprobe approach instead of having to rebuild entire kernel)
network accounting (via cgroup)
swap

memory limits shown to container are its limits, not the hosts

host-configured ip allocation per-container ; no other container can
utilize another container ip address ; no container can use an address
not allocated to it

what is the right way to do devices; and how to drop to a containers
shell from host ssh

thank you in advance
~adam
