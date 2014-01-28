From: gagandeep singh <gaganthaparian-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Subject: network namespaces
Date: Tue, 28 Jan 2014 10:26:30 +0530
Message-ID: <COL128-W8738C1ACD5845F5152ED5D9AD0@phx.gbl>
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
To: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

hi,

 

i am working on network name spaces from last 1 month . i have make a namespace configure all . and make a bridge simply using linux bridge "brctl" .everything is working fine but there is problem regarding domain name server in network namespace when i ping in network name space as 

ip netns exec myvpn ping 8.8.8.8

it works fine

but when i ping as

ip netns exec myvpn ping www.google.com

just error as ping:unknown host

after i see i should use file resolv.conf in /etc/netns/myvpn/

so i copy reolve .conf file from /etc/resolv.conf and resolvconf directory to /etc/netns/myvpn/

now when i ping in netnamespace

"i get error

bind:etc/netns/myvpn/resolve --> /etc/resolve.conf failed no such directory

time out"

please help me how to resolve it thanks 

 

Gagan

 

 

 
 		 	   		  
