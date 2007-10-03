From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/1][NETNS49] Make af_unix autobind per namespace
Date: Wed, 03 Oct 2007 17:34:10 +0200
Message-ID: <4703B672.7080502@fr.ibm.com>
References: <20071002151846.827206013@mai.toulouse-stg.fr.ibm.com>
	<m1fy0tjv04.fsf@ebiederm.dsl.xmission.com>
	<4702AF67.1010707@fr.ibm.com> <47034F4F.5000901@sw.ru>
	<47039510.7040001@fr.ibm.com>
	<m1przwe03e.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1przwe03e.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>> my 2 cnts,
>>
>> when 'restarting' a socket bound to an abstract name, we will have 
>> a EADDRINUSE if we try to rebind it to an abtract name which is 
>> already in use by a socket in a another namespace ? 
> 
> No.

ok. i just went over your AF_UNIX patch and saw that 'struct net' was 
being checked for abstract sockets.

C.

>> it seems to me that this is an identifier and like any identifier
>> it should be private to the namespace, which probably means having
>> unix_abstract_socket_table[] per net namespace.
> 
> Yes it is.  It is a hash table so we are filter the hash chain
> and not having two copies of the table.  But effectively it's
> the same thing.
> 
> All this patch was suggesting was having a per network namespace
> copy of the data structure for the random number generator for
> generating the name.  
> 
> The ``random number generator'' is just a 16bit counter that loops
> through all 64k values seeing if a name is available and if so
> using it.  Sharing our place in the loop between different namespaces
> may be ineffeicient but it should work fine.
> 
> Eric
