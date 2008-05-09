#ifndef QPID_SESSIONID_H
#define QPID_SESSIONID_H

/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

#include <boost/operators.hpp>
#include <string>

namespace qpid {

/** Identifier for a session */
class SessionId : boost::totally_ordered1<SessionId> {
    std::string userId;
    std::string name;
  public:
    SessionId(const std::string& userId=std::string(), const std::string& name=std::string());
    std::string getUserId() const { return userId; }
    std::string getName() const { return name; }
    bool operator<(const SessionId&) const ;
    bool operator==(const SessionId& id) const;
    // Convert to a string
    std::string str() const;
};

std::ostream& operator<<(std::ostream&, const SessionId&);


} // namespace qpid

#endif  /*!QPID_SESSIONID_H*/
